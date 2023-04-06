gambits.cdc = {
    type = "ws",
    name = "chant_du_cygne",
    behavior = "burn"
}
gambits.flutter = {
    type = "buff_enhancing",
    blue_magic = true,
    name = "erratic_flutter",
    buffId = 33,
    target = "self",
    focus = "single",
    minTargets = 3
}
gambits.meditation = {
    type = "buff_enhancing",
    blue_magic = true,
    name = "nat. meditation",
    buffId = 91,
    target = "self",
}

gambits.default = {
    gambits.cdc,
    gambits.flutter,
    gambits.meditation
}