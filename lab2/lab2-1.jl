function inheritance_graph(var_type)
    if(var_type == Any) print("Any");
    else
        inheritance_graph(supertype(var_type));
        print(" -> ");
        print(var_type);
    end
end

inheritance_graph(typeof(12));
