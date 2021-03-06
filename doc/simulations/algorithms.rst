Selecting the algorithms
========================

.. TODO:: Introduction

.. _simulation-integrator:

Integrator: running the simulation
----------------------------------

An integrator is an algorithm responsible for updating the positions and the
velocities of the current :ref:`frame <type-Frame>` of the :ref:`simulation
<type-Simulation>`.

.. TODO:: how to set the integrator

Verlet integrators
^^^^^^^^^^^^^^^^^^

Verlet integrators are based on Taylor expensions of Newton's second law.
They provide a simple way to integrate the movement, and conserve the energy
if a sufficently small timestep is used. Assuming the absence of barostat and
thermostat, they provide a NVE integration.

.. jl:type:: Verlet

    The Verlet algorithm is described
    `here <http://www.fisica.uniud.it/~ercolessi/md/md/node21.html>`_ for example.
    The main constructor for this integrator is ``Verlet(timestep)``, where
    ``timestep`` is the timestep in femtosecond.

.. _type-VelocityVerlet:

.. jl:type:: VelocityVerlet

    The velocity-Verlet algorithm is descibed extensively in the literature, for
    example in this `webpages <http://www.fisica.uniud.it/~ercolessi/md/md/node21.html>`_.
    The main constructor for this integrator is ``VelocityVerlet(timestep)``, where
    ``timestep`` is the integration timestep in femtosecond. This is the default
    integration algorithm in `Jumos`.



.. _simulation-checks:

Checking the simulation consistency
-----------------------------------

Molecular dynamic is usually a `garbage in, garbage out` set of algorithms. The
numeric and physical issues are not caught by the algorithm themselves, and the
physical (and chemical) consistency of the simulation should be checked often.

In `Jumos`, this is achieved by the ``Check`` algorithms, which are presented in
this section. Checking algorithms can be added to a simulation by using the
:func:`add_check` function.

Existing checks
^^^^^^^^^^^^^^^

.. jl:type:: GlobalVelocityIsNull

    This algorithm checks if the global velocity (the total moment of inertia) is
    null for the current simulation. The absolute tolerance is :math:`10^{-5}\ A/fs`.

.. jl:type:: TotalForceIsNull

    This algorithm checks if the sum of the forces is null for the current
    simulation. The absolute tolerance is :math:`10^{-5}\ uma \cdot A/fs^2`.

.. _type-AllPositionsAreDefined:

.. jl:type:: AllPositionsAreDefined

    This algorithm checks is all the positions and all the velocities are defined
    numbers, *i.e.* if all the values are not infinity or the ``NaN`` (not a number)
    values.

    This algorithm is used by default by all the molecular dynamic simulation.


.. _simulation-controls:

Controlling the simulation
--------------------------

While running a simulation, we often want to have control over some simulation
parameters: the temperature, the pressure, … This is the goal of the *Control*
algorithms.

Such algorithms are subtypes of ``BaseControl``, and can be added to a simulation
using the :func:`add_control` function:

.. _thermostat:

Controlling the temperature: Thermostats
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Various algorithms are available to control the temperature of a simulation and
perform pseudo NVT simulations. The following thermostating algorithms are
currently implemented:

.. jl:type:: VelocityRescaleThermostat

    The velocity rescale algorithm controls the temperature by rescaling all the
    velocities when the temperature differs exceedingly from the desired temperature.

    The constructor takes two parameters: the desired temperature and a tolerance
    interval. If the absolute difference between the current temperature and the
    desired temperature is larger than the tolerance, this algorithm rescales the
    velocities.

    .. code-block:: julia

        sim = MolecularDynamic(2.0)

        # This sets the temperature to 300K, with a tolerance of 50K
        thermostat = VelocityRescaleThermostat(300, 50)

        add_control(sim, thermostat)

.. jl:type:: BerendsenThermostat

    The berendsen thermostat sets the simulation temperature by exponentially
    relaxing to a desired temperature. A more complete description of this
    algorithm can be found in the original article [#berendsen]_.

    The constructor takes as parameters the desired temperature, and the coupling
    parameter, expressed in simulation timestep units. A coupling parameter of
    100, will give a coupling time of :math:`150\ fs` if the simulation timestep
    is :math:`1.5\ fs`, and a coupling time of :math:`200\ fs` if the timestep
    is :math:`2.0\ fs`.

.. function:: BerendsenThermostat(T, [coupling])

    Creates a Berendsen thermostat at the temperature ``T`` with a coupling
    parameter of ``coupling``. The default values for ``coupling`` is :math:`100`.

    .. code-block:: julia

        sim = MolecularDynamic(2.0)

        # This sets the temperature to 300K
        thermostat = BerendsenThermostat(300)

        add_control(sim, thermostat)

.. [#berendsen] H.J.C. Berendsen, *et al.* J. Chem Phys **81**, 3684 (1984); doi: 10.1063/1.448118

.. _barostat:

Controlling the pressure: Barostats
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. jl:type:: BerendsenBarostat

    TODO

Other controls
^^^^^^^^^^^^^^

.. _type-WrapParticles:

.. jl:type:: WrapParticles

    This control wraps the positions of all the particles inside the :ref:`unit
    cell <type-UnitCell>`.

    This control is present by default in the molecular dynamic simulations.


Functions for algorithms selection
==================================

The six following functions are used to to select specific algorithms for the
simulation. They allow to add and change all the algorithms, even in the middle
of a run.

.. function:: set_integrator(sim, integrator)

    Sets the simulation integrator to ``integrator``.

    Usage example:

    .. code-block:: julia

        # Creates the integrator directly in the function
        set_integrator(sim, Verlet(2.5))

        # Binds the integrator to a variable if you want to change a parameter
        integrator = Verlet(0.5)
        set_integrator(sim, integrator)
        run!(sim, 300)   # Run with a 0.5 fs timestep
        integrator.timestep = 1.5
        run!(sim, 3000)  # Run with a 1.5 fs timestep

.. function:: set_forces_computation(sim, forces_computer)

    Sets the simulation algorithm for forces computation to ``forces_computer``.

.. function:: add_check(sim, check)

    Adds a :ref:`check <simulation-checks>` to the simulation check list and
    issues a warning if the check is already present.

    Usage example:

    .. code-block:: julia

        # Note the parentheses, needed to instanciate the new check.
        add_check(sim, AllPositionsAreDefined())

.. function:: add_control(sim, control)

    Adds a :ref:`control <simulation-controls>` algorithm to the simulation
    list. If the control algorithm is already present, a warning is issued.

    Usage example:

    .. code-block:: julia

        add_control(sim, RescaleVelocities(300, 100))

.. function:: add_compute(sim, compute)

    Adds a :ref:`compute <simulation-computes>` algorithm to the simulation
    list. If the algorithm is already present, a warning is issued.

    Usage example:

    .. code-block:: julia

        # Note the parentheses, needed to instanciate the new compute algorithm.
        add_compute(sim, EnergyCompute())

.. function:: add_output(sim, output)

    Adds an :ref:`output <simulation-outputs>` algorithm to the simulation
    list. If the algorithm is already present, a warning is issued.

    Usage example:

    .. code-block:: julia

        add_output(sim, TrajectoryOutput("mytraj.xyz"))
