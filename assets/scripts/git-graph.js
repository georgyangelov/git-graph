(function(window, document) {
    "use strict";

    sigma.settings.drawLabels = false;
    sigma.settings.enableHovering = false;
    sigma.settings.maxNodeSize = 30;
    sigma.settings.maxEdgeSize = 30;

    sigma.settings.nodesPowRatio = 0.9;
    sigma.settings.edgesPowRatio = 1;

    var s = new sigma({
            renderers: [{
                container: document.getElementById('container'),
                type: 'canvas'
            }]
        });

    function test() {
        // Then, let's add some data to display:
        s.graph.addNode({
            // Main attributes:
            id: 'n0',

            // Display attributes:
            x: 0,
            y: 0,
            size: 20,
            color: '#f00',
            type: 'commit',

            data: {
                sha1: '13c620b630b3895e7b71fe23c485687792fa4421',
                message: 'Merge remote-tracking branch \'origin/pr/329\'' +
                         '    Conflicts:' +
                         '        test/unit.html'
            }
        }).addNode({
            // Main attributes:
            id: 'n1',

            // Display attributes:
            x: 0,
            y: 0.1,
            size: 20,
            type: 'commit',

            data: {
                sha1: '4df6209033e56848bc7d36be372c23bea21da12e',
                message: 'corrected tempRes variable reset: object and not variable'
            }
        }).addEdge({
          id: 'e0',
          // Reference extremities:
          source: 'n0',
          target: 'n1',
          size: 1
        });

        // Finally, let's ask our sigma instance to refresh:
        s.refresh();
    }

    test();

})(window, document);
