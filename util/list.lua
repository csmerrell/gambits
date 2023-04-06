List = {}

function List.create()
    list = { 
        head = nil,
        tail = nil,
        size = 0
    }
    list.at = function(self, pos) 
        return List.at(self, pos) 
    end
    list.prepend = function(self, val)
        self = List.prepend(self, val)
    end
    list.append = function(self, val)
        self = List.append(self, val)
    end
    list.popFront = function(self, val)
        self = List.popFront(self, val)
    end
    list.popBack = function(self, val)
        self = List.popBack(self, val)
    end
    list.first = function(self)
        return List.first(self)
    end
    list.last = function(self)
        return List.last(self)
    end
    list.destroy = function(self)
        return List.last(self)
    end

    return list
end

function List.destroy(list)
    node = list.head
    while node do
        node.value = nil
        if node.next then
            nextNode = node.next
            node.next = nil
            node = nextNode
        end
    end
    list.head = nil
    list.tail = nil
    list.size = nil
    list = nil
end

function List.nodeAt(list, pos)
    if pos > list.size then return nil end

    i = 1
    node = list.head
    while node do
        if i == pos then
            return node
        else
            node = node.next
            i = i + 1
        end
    end
    return nil
end

function List.at(list, pos)
    return List.nodeAt(list, post).value
end

function List.prepend(list, val)
    newNode = { next = list.head, value = val }
    list.head = newNode
    if list.size == 0 then
        list.tail = newNode
    end
    list.size = list.size + 1
    return list
end

function List.append(list, val)
    newNode = { next = nil, value = val }
    if list.tail then
        list.tail.next = newNode
    end
    list.tail = newNode
    if list.size == 0 then
        list.head = newNode
    end
    list.size = list.size + 1
    return list
end

function List.popFront(list)
    if list.head then
        node = list.head
        list.head = node.next
        list.size = list.size - 1
        return node.value
    else
        return nil
    end
end

function List.popBack(list)
    if list.tail then
        node = list.tail
        newTail = List.nodeAt(list, list.size - 1)
        list.size = list.size - 1
        newTail.next = nil
        return node.value
    else
        return nil
    end
end

function List.first(list)
    if list.head then
        return list.head.value
    else
        return nil
    end
end

function List.last(list)
    if list.tail then
        return list.tail.value
    else
        return nil
    end
end

return List