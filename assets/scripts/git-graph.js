(function(window, document) {
    "use strict";

    sigma.settings.drawLabels = false;
    sigma.settings.enableHovering = false;
    sigma.settings.maxNodeSize = 30;
    sigma.settings.maxEdgeSize = 30;
    sigma.settings.autoRescale = false;

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

    var step = {
        x: 40 * 3,
        y: 40
    };

    var nodes_added = {},
        edges_added = {};

    function build_graph(x, y, history) {
        add_nodes(x, y, history, Object.keys(history)[0]);
        add_edges(history);

        s.refresh();
    }

    function add_nodes(x, y, history, start_sha1) {
        var commit = history[start_sha1],
            forks = [];

        if (!commit) {
            console.log('Cannot find commit', start_sha1);
            return;
        }

        while (true) {
            if (nodes_added[commit.sha1]) {
                break;
            }

            add_commit_node(x, y, commit);

            if (commit.parents.length === 0) {
                break;
            }

            if (commit.parents.length > 1) {
                for (var i = 1; i < commit.parents.length; i++) {
                    forks.push({x: x + step.x, y: y + step.y, commit: commit.parents[i]});
                }
            }

            if (!history[commit.parents[0]]) {
                console.log('Cannot find commit', start_sha1);
                return;
            }

            commit = history[commit.parents[0]];
            y += step.y;
        }

        forks.forEach(function(data) {
            add_nodes(data.x, data.y, history, data.commit);
        });
    }

    function add_commit_node(x, y, commit) {
        nodes_added[commit.sha1] = true;

        s.graph.addNode({
            id: commit.sha1,
            x: x,
            y: y,
            size: 20,
            type: 'commit',

            data: commit
        });
    }

    function add_edges(history) {
        var commit,
            commits = [ history[Object.keys(history)[0]] ];

        while (commits.length) {
            commit = commits.shift();

            commit.parents.forEach(function(parent_sha1) {
                if (edges_added[commit.sha1 + '->' + parent_sha1]) {
                    return;
                }

                add_edge(commit.sha1, parent_sha1);

                if (!history[parent_sha1]) {
                    console.log('Cannot find commit', start_sha1);
                    return;
                }

                commits.push(history[parent_sha1]);
            });
        }
    }

    function add_edge(id1, id2) {
        edges_added[id1 + '->' + id2] = true;

        s.graph.addEdge({
            id: id1 + '->' + id2,

            source: id1,
            target: id2,

            size: 1
        });
    }

    // test();
    loadJSON('history.json', function(history) {
        console.log(history);
        build_graph(0, 0, history);
    });

    function loadJSON(url, next) {
        var xobj = new XMLHttpRequest();
        xobj.overrideMimeType("application/json");
        xobj.open('GET', url, true);

        xobj.onreadystatechange = function() {
            if (xobj.readyState == 4 && xobj.status == "200") {
                next(window.JSON.parse(xobj.responseText));
            }
        };

        xobj.send(null);
    }

})(window, document);
