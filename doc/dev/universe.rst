Universe
========

The Universe module defines base data types used in the other modules.

.. _type-Array3D:

Array3D
-------

3-dimensionals vectors are very common in molecular simulations. The ``Array3D``
type implements arrays of this kind of vectors, provinding all the usual
operations between its components.

If ``A`` is an ``Array3D`` and ``i`` an integer, ``A[i]`` is a 3-dimensional
vector implementing ``+, -`` between vector, ``.+, .-, .*, */`` between vectors
and scalars; ``dot`` and ``cross`` products, and the ``unit!`` function,
normalizing its argument.

.. _type-UnitCell:

Simulation Cell
---------------

A simulation cell (``UnitCell`` type) is the virtual container in which all the
particles of a simulation move. There are three different types of simulation
cells :

- Infinite cells (``InfiniteCell``) do not have any boundaries. Any move
  is allowed inside these cells;
- Orthorombic cells (``OrthorombicCell``) have up to three independent lenghts;
  all the angles of the cell are set to 90° (:math:`\pi/2` radians)
- Triclinic cells (``TriclinicCell``) have 6 independent parameters: 3 lenghts and
  3 angles.

Creating simulation cell
^^^^^^^^^^^^^^^^^^^^^^^^

.. function:: UnitCell(Lx, [Ly, Lz, alpha, beta, gamma, celltype])

    Creates an unit cell. If no ``celltype`` parameter is given, this function tries
    to guess the cell type using the following behavior: if all the angles are
    equals to :math:`\pi/2`, then the cell is an ``OrthorombicCell``; else, it
    is a ``TriclinicCell``.

    If no value is given for ``alpha, beta, gamma``, they are set to :math:`\pi/2`.
    If no value is given for ``Ly, Lz``, they are set to be equal to ``Lx``.
    This creates a cubic cell. If no value is given for ``Lx``, a cell with lenghts
    of :math:`0 A` and :math:`\pi/2` angles is constructed.

    .. code-block:: jlcon

        julia> UnitCell() # Without parameters
        OrthorombicCell
            Lenghts: 0.0, 0.0, 0.0

        julia> UnitCell(10.) # With one lenght
        OrthorombicCell
            Lenghts: 10.0, 10.0, 10.0

        julia> UnitCell(10., 12, 15) # With three lenghts
        OrthorombicCell
            Lenghts: 10.0, 12.0, 15.0

        julia> UnitCell(10, 10, 10, pi/2, pi/3, pi/5) # With lenghts and angles
        TriclinicCell
            Lenghts: 10.0, 10.0, 10.0
            Angles: 1.5707963267948966, 1.0471975511965976, 0.6283185307179586

        julia> UnitCell(InfiniteCell) # With type
        InfiniteCell

        julia> UnitCell(10., 12, 15, TriclinicCell) # with lenghts and type
        TriclinicCell
            Lenghts: 10.0, 12.0, 15.0
            Angles: 1.5707963267948966, 1.5707963267948966, 1.5707963267948966

.. function:: UnitCell(u::Vector, [v::Vector, celltype])

    If the size matches, this function expands the vectors and returns the
    corresponding cell.

    .. code-block:: jlcon

        julia> u = [10, 20, 30]
        3-element Array{Int64,1}:
         10
         20
         30

        julia> UnitCell(u)
        OrthorombicCell
            Lenghts: 10.0, 20.0, 30.0

Indexing simulation cell
^^^^^^^^^^^^^^^^^^^^^^^^

You can access the cell size and angles either directly, or by integer indexing.

.. function:: getindex(b::UnitCell, i::Int)

    Calling ``b[i]`` will return the corresponding length or angle : for ``i in
    [1:3]``, you get the ``i``:superscript:`th` lenght, and for ``i in [4:6]``,
    you get [avoid get] the angles.

    In case of intense use of such indexing, direct field access should be
    more efficient. The internal fields of a cell are : the three lenghts
    ``x, y, z``, and the three angles ``alpha, beta, gamma``.

Boundary conditions and cells
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Only fully periodic boundary conditions are implemented for now. This means that
if a particle crosses the boundary at some step, it will be wrapped up and will
appear at the opposite boundary.

Distances and cells
^^^^^^^^^^^^^^^^^^^

The distance between two particles depends on the cell type. In all cases, the
minimal image convention is used: the distance between two particles is the
minimal distance between all the images of theses particles. This is explicited
in the :ref:`distances` part of this documentation.

.. _type-Frame:

Frame
-----

A ``Frame`` object holds the data from one step of a simulation. It is defined as

.. code-block:: julia

    type Frame
        step::Integer
        cell::UnitCell
        topology::Topology
        positions::Array3D
        velocities::Array3D
    end

`i.e.` it contains information about the current step, the current
:ref:`cell <type-UnitCell>` shape, the current :ref:`topology <type-Topology>`,
the current positions, and possibly the current velocities. If there is no
velocity information, the velocities ``Array3D`` is a 0-sized array.

Creating frames
^^^^^^^^^^^^^^^

There are two ways to create frames: either explicitly or implicity. Explicit
creation uses one of the constructors below. Implicit creation occurs while
reading frames from a stored trajectory or from running a simulation.

The Frame type have the following constructors:

.. function:: Frame(::Topology)

    Creates a frame given a topology. The arrays are pre-allocated to store data
    according to the topology.

.. function:: Frame()

    Creates an empty frame, with a 0-atoms topology.

Reading and writing frames from files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The main goal of the ``Trajectories`` module is to read or write frames from or to
files. See this module :ref:`documentation <trajectories>` for more information.
