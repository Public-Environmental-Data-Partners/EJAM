# namez (DATA) list of lists of indicator names (complete list in 1 object)

namez (DATA) list of lists of indicator names (complete list in 1
object)

## Details

Not yet used in EJAM

This is a list of lists of indicator names, with the complete list in
one object. Indicator names are used in various functions and analyses
in EJAM, and are organized in groups called variable lists (e.g.,
"names_e" contains environmental indicator names). The info about which
names are in which list is also stored in map_headernames columns
"rname" and "varlist" as checked like this for example: varinfo(names_e,
"varlist")

namez is an alternative way of storing those names, and was drafted as
another option that might get used. Instead of an approach where
indicator names are stored in variable lists like "names_e", "names_d",
etc., namez is a list where one element contains what names_e contains,
etc. For example, namez\$e_state_pctile is a vector just like
names_e_state_pctile, and contains the same indicator names:

    cbind(names_e_state_pctile, `namez$e_state_pctile` = namez$e_state_pctile)

You can see all the variable lists stored by namez this way:

    names(namez)

You can see them in the familiar format used by the variable lists this
way:

    paste0("names_", names(namez))

You can see all the variable lists stored by map_headernames this way:

    unique(map_headernames$varlist)
    cbind(object_exists = sapply(unique(map_headernames$varlist), exists))

"names_all_r" also exists and is a name in namez even though there is no
such designation used in map_headernames.

"custom" versus "names_custom" may be used inconsistently in
map_headernames\$varlist, and was just a placeholder.

## See also

[`varinfo()`](https://public-environmental-data-partners.github.io/EJAM/reference/varinfo.md)
[map_headernames](https://public-environmental-data-partners.github.io/EJAM/reference/map_headernames.md)
[names_d](https://public-environmental-data-partners.github.io/EJAM/reference/names_d.md)
[names_e](https://public-environmental-data-partners.github.io/EJAM/reference/names_e.md)
