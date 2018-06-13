using Base.Filesystem
#################### PRODUCER #############################

function producer(c_names :: Channel)
    for (root, _dirs, files) in walkdir("./")
        for file in files
            println(file)
            put!(c_names, file)
        end
    end
    close(c_names)
end

#################### CONSUMER #############################

function consumer(c_names :: Channel, c_linenum :: Channel)
    for filename in c_names
        println(file)
        file = open(filename)
        lines_num = countlines(file)
        close(file)
        put!(c_linenum, lines_num)
    end
    
end

#################### MAIN #############################

function main(pathname :: String, consumers_no :: Int64)
    oldpwd :: String = pwd() 
    cd(pathname)
    # File names
    # Flow: producer -> consumer
    c_names = Channel{String}(64)
    # Calculated number of lines
    # Flow: consumer -> main 
    c_linenum = Channel{Int64}(64)

    # Spawn tasks
    @async producer(c_names)
    for i=1:consumers_no
        @async consumer(c_names, c_linenum)
    end    

    # Reduce all consumer outputs to a sum
    linenum :: Int64 = 0
    for i in c_linenum
        linenum += i
    end

    close(c_linenum)
    cd(pwd)
    return linenum
end