using Plots
using DataFrames
using Gadfly
Plots.gr()

@everywhere function generate_julia(z; c=2, maxiter=200)
    for i=1:maxiter
        if abs(z) > 2
            return i-1
        end
        z = z^2 + c
    end
    maxiter
end

@everywhere function calc_julia!(julia_set, xrange, yrange; maxiter=200, height=400, width_start=1, width_end=400)
    for x=width_start:width_end
        for y=1:height
            z = xrange[x] + 1im*yrange[y]
            julia_set[x, y] = generate_julia(z, c=-0.70176-0.3842im, maxiter=maxiter)
        end
    end
    julia_set[width_start:width_end, :]
end

@everywhere function calc_for_range(jobs, results, julia_set, xrange, yrange, h)
    while true
        job = try take!(jobs) end
        if job == nothing
            break
        end
        (s,e) = job
        put!(results, calc_julia!(julia_set, xrange, yrange, height=h, width_start=s, width_end=e))
    end
end

function calc_julia_main(h, w, chunck_len)
    xmin, xmax = -2,2
    ymin, ymax = -1,1
    xrange = linspace(xmin, xmax, w)
    yrange = linspace(ymin, ymax, h)
    julia_set = SharedArray(Int64, (w, h))
    
    # Chunk array
    jobs = [] 
    jobs_ch = RemoteChannel(()-> Channel{Tuple{Int64, Int64}}(100));
    results = RemoteChannel(() -> Channel{Array{Int64}}(10000))
    
    last_end = 0
    stripes = 0
    while (last_end < w) 
        start = last_end + 1
        last_end = start + chunck_len - 1
        stripes += 1
        if(last_end > w) 
            last_end = w
            push!(jobs, (start, last_end))
            break
        end
        push!(jobs, (start, last_end))
    end

    # Time
    tic()

    foreach(worker -> remote_do(calc_for_range, worker, jobs_ch, results, julia_set, xrange, yrange, h), workers())
    foreach(job -> put!(jobs_ch, job), jobs)
    
    close(jobs_ch)

    data = Array{Int64}((0,h))
    
    for _ in 1:stripes
        data = vcat(data, take!(results))
    end

    close(results)

    time = toq()

    Plots.heatmap(xrange, yrange, data)
    png("julia")

    return time
end

function julia_time_and_plot(width=2000, height=2000) 
    measurements = DataFrame()
    measurements[:time] = 0.0
    measurements[:chunck] = 0
    chunck_len = 1
    while chunck_len < width
        measurement = DataFrame()
        measurement[:time] = calc_julia_main(height, width, chunck_len)
        measurement[:chunck] = chunck_len
        append!(measurements, measurement)

        chunck_len = chunck_len + div(width, 40)
    end
    plot(measurements, x = "chunck", y = "time", Geom.bar(position=:dodge))
end

julia_time_and_plot()