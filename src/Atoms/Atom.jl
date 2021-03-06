# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                       Atom type in topologies
# ============================================================================ #

import Base.show

export Atom, get_mass, set_mass!

type Atom
    name::String                # atom name
    symbol::String              # atom chemical type
    mass::Float64               # atomic mass
    special::Dict{String, Any}  # special values (charge, ...)
end

Atom(s::String) = Atom(s, s, get_mass(s), Dict())
Atom() = Atom("")

function show(io::IO, atom::Atom)
    show(io, "Atom $(atom.name) ($(atom.symbol))")
end

function get_mass(atom::Atom)
    mass = get_mass(atom.symbol)
    if mass == 0.0 # Mass not found
        mass = get_mass(atom.name)
    end
    return mass
end

function get_mass(name::String)
    mass = 0.0
    if haskey(ATOMIC_MASSES, name)
        # TODO: fix the method error is internal(ATOMIC_MASSES[name])
        mass =  ATOMIC_MASSES[name].val
    end
    return mass
end

function set_mass!(atom::Atom)
    atom.mass = get_mass(atom)
end

function set_mass!(atom::Atom, mass::Number)
    atom.mass = mass
end

function (==)(this::Atom, other::Atom)
    for name in names(Atom)
        if getfield(this, name) != getfield(other, name)
            return false
        end
    end
    return true
end
