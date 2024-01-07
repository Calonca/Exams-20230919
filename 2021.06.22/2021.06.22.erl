-module(echo).


node_wait(Parent, Elem, Children) ->
  receive
    {register_child, Child, Weight} ->
      node_wait(Parent, Elem, [{Child, Weight} | Children]);
    {get_distance, Value} -> 
      if
        Value == Elem ->
          Parent ! {self(), 0};
        true -> search_in_children(Children);
      end.
  end.

search_in_children(Origin, Distance,Value,Children)->
  for C,Weight in Children:
    C! {self(), {get_distance, Value}}
  if found -> 




