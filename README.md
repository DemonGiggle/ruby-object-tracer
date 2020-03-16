# ruby-object-tracer
Construct object space graph in `graphviz` format


# Usage

```
ruby main.rb -t HelloTreasure -i samples/heap.json
```

Since there's lots of stuffs in the memory, we only choose the string "HelloTreasure" as the starting point.

All references referenced by the start point will be traced as the next layer, and this layer will be 
traced for the next layer until there nothing to trace.

Currently, we only support string type as the initial starting point.

The output is `out.dot` which can be rendered via 

```
xdot out.dot
```

xdot can be downloaded from [here](https://github.com/jrfonseca/xdot.py)
