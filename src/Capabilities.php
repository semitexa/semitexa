<?php

declare(strict_types=1);

namespace Semitexa\Ultimate;

use Semitexa\Core\Attribute\Capability;

/**
 * What this package offers, for the capability catalog.
 *
 * Unusual placement, on purpose: this is a project skeleton, so the file lands
 * in every project created from it and describes what that project was built
 * out of. It is the one declaration a reader normally already has installed by
 * the time they can read it — kept so that the set of packages carrying a
 * `Capabilities` class is the whole set, with no exception to remember.
 *
 * Nothing reads this at runtime.
 */
#[Capability(
    id: 'dist.ultimate',
    summary: 'The full-stack distribution: a project skeleton with the core packages, docs, container files and a working example module already wired.',
    useWhen: 'Starting a new Semitexa project, and the first commit should already boot, render and pass its tests.',
    avoidWhen: 'Adding Semitexa to an application that already exists — require the individual packages rather than adopting a skeleton around them.',
    replaces: [
        'assembling the package set, container files and module layout by hand for each new project',
        'copying the previous project and deleting whatever does not apply',
    ],
)]
final class Capabilities
{
}
