config = require('config')

default = {
    roll = L{'Ninja Roll','Corsair\'s Roll'},
    active = true,
    crooked_cards = 1,
    text = {text = {size=10}},
    autora = true,
    aoe = {['p1'] = true,['p2'] = true,['p3'] = true,['p4'] = true,['p5'] = true},                    
}

settings = config.load(default)