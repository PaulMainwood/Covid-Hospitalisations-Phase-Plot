using CSV, DataFrames, Plots, HTTP, RollingFunctions, Statistics, Dates

url = "https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaCode=E92000001&metric=newAdmissions&metric=hospitalCases&format=csv"
data = CSV.File(HTTP.get(url).body) |> DataFrame
sort!(data, :date)

last_values = dropmissing(data)[end, 4:end]

#Roll up the admissions and beds to 7-day means
rolled_data = DataFrame(dates = data.date[7:end], admits_week = rolling(mean, data.newAdmissions, 7), beds_week = rolling(mean, data.hospitalCases, 7))
end_of_wave_1 = Date(2020, 8, 15)
end_of_wave_2 = Date(2021, 4, 15)
end_of_wave_3 = Date(2022, 2, 22)

df1 = filter(row -> row.dates < end_of_wave_1, rolled_data)
df2 = filter(row -> row.dates >= end_of_wave_1 && row.dates < end_of_wave_2, rolled_data)
df3 = filter(row -> row.dates >= end_of_wave_2 && row.dates < end_of_wave_3, rolled_data)
df4 = filter(row -> row.dates >= end_of_wave_3, rolled_data)

gr(display_type=:inline)

#Plot scatters, in four builds
a = scatter(df1.admits_week, df1.beds_week, xlabel = "Admissions", xlims = (0, 4000), xticks = 0:1000:5000, ylabel = "Beds full", ylims = (0, 40000), yticks = ([0:10000:50000;], ["0", "10,000", "20,000", "30,000", "40,000"]), size = (500, 500), markercolor = :white, markerstrokecolor = :red, title = "Phase portrait of England hospitalisations", label = "Wave 1", legend=:topleft)
scatter!(a, df2.admits_week, df2.beds_week, markercolor = :white, markerstrokecolor = :blue, label = "Wave 2")
scatter!(a, df3.admits_week, df3.beds_week, markercolor = :white, markerstrokecolor = :green, label = "Wave 3")
scatter!(a, df4.admits_week, df4.beds_week, markercolor = :white, markerstrokecolor = :black, label = "BA.2")
scatter!(a, [last_values.newAdmissions], [last_values.hospitalCases], marker = :x, markercolor = :black, label = "Latest")
