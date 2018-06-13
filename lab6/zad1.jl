global counter = 0

function write_n(n :: Int64) 
    global counter
    i = 0
    while i < 5
        if (counter % 3 + 1) == n
            print("$n \n")
            flush(STDOUT)
            counter += 1
            i += 1 
        else 
            sleep(rand() % 0.001)
        end
    end    
end    

function run_tasks()
    global counter = 0
    task1 = @task write_n(3)
    task2 = @task write_n(2)
    task3 = @task write_n(1)
    tasks = [task1; task2; task3]
    # Schedule tasks in random order
    for i in shuffle(1:3)
        print("[Scheduling task $i] \n")
        schedule(tasks[i])
    end    
end    