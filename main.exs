defmodule SpaceObject do
  defstruct name: "COM", parent: nil

  def parent_node(%{parent: parent}, all_nodes) do
    Enum.find(all_nodes, fn(%{name: name}) -> parent == name end)
  end

  def all_parents(nil, _, _) do
    []
  end

  def all_parents(%{parent: nil}, _, _) do
    []
  end

  def all_parents(node = %{parent: parent}, all_nodes, depth) do
    parent = SpaceObject.parent_node(node, all_nodes)
    [%{parent: parent.name, depth: depth} | SpaceObject.all_parents(parent, all_nodes, depth + 1)]
  end

  def children(node = %{name: name}, all_nodes) do
    Enum.filter(all_nodes, fn(child) ->
      parent = SpaceObject.parent_node(child, all_nodes)
      parent && parent.name == name
    end)
  end

  def orbit_count(parent, all_nodes, depth) do
    children = SpaceObject.children(parent, all_nodes)
    if Enum.empty?(children) do
      0
    else
      Enum.count(children) * depth + Enum.sum(Enum.map(children, fn(child) ->
        SpaceObject.orbit_count(child, all_nodes, depth + 1)
      end))
    end
  end
end

defmodule Main do

  def run_example do

    {:ok, contents} = File.read("data.txt")

    lines = contents |> String.split("\n", trim: true)

    objects = [%SpaceObject{name: "COM"}] ++ Enum.map(lines, fn(line) ->
      [parent, child] = String.split(line, ")", trim: true)
     %SpaceObject{name: child, parent: parent}
    end)

  sample = Enum.find(objects, fn(obj) -> obj.name == "COM" end)

  IO.puts sample.name
  IO.puts SpaceObject.orbit_count(sample, objects, 1)

  san = Enum.find(objects, fn(obj) -> obj.name == "SAN" end)
  you = Enum.find(objects, fn(obj) -> obj.name == "YOU" end)

  san_parents = SpaceObject.all_parents(san, objects, 0)
  you_parents = SpaceObject.all_parents(you, objects, 0)

  common = Enum.reject(Enum.map(san_parents, fn(%{parent: parent, depth: depth}) ->
    common_parent = Enum.find(you_parents, fn(%{parent: you_parent}) -> you_parent == parent end)
    if is_nil(common_parent) do
      nil
    else
      %{parent: parent, depth: common_parent.depth + depth}
    end
    end), &is_nil/1)
  IO.puts(Enum.min(Enum.map(common, fn(c) -> c.depth end)))
  end

end

  Main.run_example()
