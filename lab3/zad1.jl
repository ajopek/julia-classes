function allocate_n_strings(n ::Integer)
    for i = 1:n
        a = Base.Random.randstring(Base.Random.GLOBAL_RNG, 10);
    end
end

function func1()
    allocate_n_strings(10000);
end

function func2()
    allocate_n_strings(100000);
end

function profiler_test()
    for i = 1:500
        i % 2 == 0 ? func1() : func2();
    end
end

profiler_test()
Profile.clear()
@profile profiler_test()
Profile.print()

func1()
func2()
@time func1()
@time func2()
