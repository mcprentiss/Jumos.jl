# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#       Implementation of the XYZ trajectories Reader
#
# XYZ format is a text-based format, with atomic informations arranged as:
#    <name> <x> <y> <z> [<vx> <vy> <vz>]
# The two first lines of each frame contains a comment header, and the number
# of atoms.
# ============================================================================ #

type XYZReader <: FormatReader
    file::IOStream
    cell::UnitCell
end

register_reader(extension="xyz", filetype="XYZ", reader=XYZReader)

# Constructor of XYZReader: open the file and get some informations
function XYZReader(filename::String; kwargs...)

    cell = UnitCell(get_in_kwargs(kwargs, :cell, UnitCell()))
    if cell == UnitCell()
        warn("No unit cell size while opening XYZ trajectories")
    end

    file = open(filename, "r")
    return XYZReader(file, cell)
end

function get_traj_infos(r::XYZReader)
    natoms = int(readline(r.file))
    seekstart(r.file)
    nlines = countlines(r.file)
    seekstart(r.file)
    nsteps = int(nlines/(natoms + 2))
    if !(nlines%(natoms + 2) == 0)
        filename = split(r.file.name)[2][1:end-1]
        error("Wrong number of lines in file $filename")
    end
    return natoms, nsteps
end

# Read a given step of am XYZ Trajectory
function read_frame!(traj::Reader{XYZReader}, step::Integer, frame::Frame)
    if !(step == traj.current_step+1)
        go_to_step!(traj.reader, step)
        traj.current_step = step
    end
    if step > traj.nsteps || step < 1
        max = traj.nsteps
        error("Can not read step $step. Maximum step: $max")
    end
    return read_next_frame!(traj, frame)
end

# Read the next step of a trajectory.
# Assumes that the cursor is already at the good place.
# Return True if there is still some step to read, false otherwhile
function read_next_frame!(traj::Reader{XYZReader}, frame::Frame)
    traj.natoms = int(readline(traj.reader.file))

    set_frame_size!(frame, traj.natoms)

    readline(traj.reader.file)  # comment

    for i = 1:traj.natoms
        line = readline(traj.reader.file)
        position = read_atom_from_line(line)
        frame.positions[i] = position
    end
    frame.cell = traj.reader.cell
    frame.step = traj.current_step
    traj.current_step += 1
    if traj.current_step >= traj.nsteps
        return false
    else
        return true
    end
end

# Read the atomic informations from a line of a XYZ file
function read_atom_from_line(line::String)
    sp = split(line)
    return [float32(sp[2]), float32(sp[3]), float32(sp[4])]
end

# Move file cursor to the first line of the step.
function go_to_step!(traj::XYZReader, step::Integer)
    seekstart(traj.file)
    current = 1
    while current < step
        natoms = int(readline(traj.file))
        for i=1:(natoms + 1)
            readline(traj.file)
        end
        current+=1
    end
    return nothing
end
