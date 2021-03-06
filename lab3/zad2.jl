module Graphs

using StatsBase

export GraphVertex, NodeType, Person, Address,
       generate_random_graph, get_random_person, get_random_address, generate_random_nodes,
       convert_to_graph,
       bfs, check_euler, partition,
       graph_to_str, node_to_str,
       test_graph

#= Single graph vertex type.
Holds node value and information about adjacent vertices =#
struct GraphVertex
  value
  neighbors ::Vector
end

# Types of valid graph node's values.
abstract type NodeType end

struct Person <: NodeType
  name
end

struct Address <: NodeType
  streetNumber :: Int64
end

#N = 800

#K = 10000


#= Generates random directed graph of size N with K edges
and returns its adjacency matrix.=#
function generate_random_graph(N :: Int64, K :: Int64)
    A = Array{Int64,2}(N, N)
    A[:,:] = 0

    for i in sample(1:N*N, K, replace=false)
      row, col = ind2sub(size(A), i)
      A[row,col] = 1
      A[col,row] = 1
    end
    A
end

# Generates random person object (with random name).
function get_random_person()
  Person(randstring())
end

# Generates random person object (with random name).
function get_random_address()
  Address(rand(1:100))
end

# Generates N random nodes (of random NodeType).
function generate_random_nodes(N :: Int64)
  nodes = Vector()
  for i= 1:N
    push!(nodes, rand() > 0.5 ? get_random_person() : get_random_address())
  end
  nodes
end

#= Converts given adjacency matrix (NxN)
  into list of graph vertices (of type GraphVertex and length N). =#
function convert_to_graph(A :: Array{Int64,2}, nodes, N::Int64, graph :: Array{GraphVertex, 1})
  N :: Int64 = length(nodes)
  push!(graph, map(n -> GraphVertex(n, GraphVertex[]), nodes)...)

  for i = 1:N, j = 1:N
      if A[i,j] == 1
        push!(graph[i].neighbors, graph[j])
      end
  end
end

#= Groups graph nodes into connected parts. E.g. if entire graph is connected,
  result list will contain only one part with all nodes. =#
function partition(graph :: Array{GraphVertex, 1})
  parts = []
  remaining = Set(graph)
  visited = bfs(remaining=remaining)
  push!(parts, Set(visited))

  while !isempty(remaining)
    new_visited = bfs(visited=visited, remaining=remaining)
    push!(parts, new_visited)
  end
  parts
end

#= Performs BFS traversal on the graph and returns list of visited nodes.
  Optionally, BFS can initialized with set of skipped and remaining nodes.
  Start nodes is taken from the set of remaining elements. =#
function bfs(;visited=Set(), remaining=Set(graph))
  first = next(remaining, start(remaining))[1]
  q = [first]
  push!(visited, first)
  delete!(remaining, first)
  local_visited = Set([first])

  while !isempty(q)
    v = pop!(q)

    for n in v.neighbors
      if !(n in visited)
        push!(q, n)
        push!(visited, n)
        push!(local_visited, n)
        delete!(remaining, n)
      end
    end
  end
  local_visited
end

#= Checks if there's Euler cycle in the graph by investigating
   connectivity condition and evaluating if every vertex has even degree =#
function check_euler(graph::Array{GraphVertex, 1})
  if length(partition(graph)) == 1
    return all(map(v -> iseven(length(v.neighbors)), graph))
  end
    "Graph is not connected"
end

#= Returns text representation of the graph consisiting of each node's value
   text and number of its neighbors. =#
function graph_to_str(graph::Array{GraphVertex, 1})
  graph_str = ""
  for v in graph
    graph_str *= "****\n"

    n = v.value
    if isa(n, Person)
      node_str = "Person: $(n.name)\n"
    else isa(n, Address)
      node_str = "Street nr: $(n.streetNumber)\n"
    end

    graph_str *= node_str
    graph_str *= "Neighbors: $(length(v.neighbors))\n"
  end
  graph_str
end

#= Tests graph functions by creating 100 graphs, checking Euler cycle
  and creating text representation. =#
function test_graph()
  for i=1:100
    graph = GraphVertex[]

    const N = 800
    const K = 10000

    A = generate_random_graph(N, K)
    nodes = generate_random_nodes(N)
    convert_to_graph(A, nodes, N, graph)

    str = graph_to_str(graph)
    #println(str)
    #println(check_euler())
    check_euler(graph)
  end
end

@time Graphs.test_graph()

end
