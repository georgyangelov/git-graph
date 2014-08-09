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

    function build_graph(x, y, history) {
        add_nodes(x, y, history, Object.keys(history)[0]);
        add_edges(history);

        s.refresh();
    }

    function add_nodes(x, y, history, start_sha1) {
        var queue = new PriorityQueue({
                strategy: PriorityQueue.BinaryHeapStrategy,
                comparator: function(a, b) {
                    var r = b.commit.timestamp - a.commit.timestamp;

                    if (r === 0) {
                        return Math.abs(a.column) - Math.abs(b.column);
                    }

                    return r;
                }
            }),
            y = 0,
            added = {},
            columns = {},
            current;

        columns[0] = true;
        queue.queue({column: 0, commit: history[start_sha1]});

        while (queue.length) {
            current = queue.dequeue();

            columns[current.column] = false;

            if (added[current.commit.sha1]) {
                continue;
            }

            added[current.commit.sha1] = true;

            add_commit_node(current.column * step.x, y, current.commit);
            y += step.y;

            for (var i = 0; i < current.commit.parents.length; i++) {
                var sha1 = current.commit.parents[i];

                if (!history[sha1]) {
                    console.log('Cannot find commit', sha1);
                }

                queue.queue({column: nearest_column(columns, current.column), commit: history[sha1]});
            }
        }
    }

    function nearest_column(columns, current) {
        var column_delta     = 0,
            column_delta_abs = 0;

        while (true) {
            if (!columns[current + column_delta_abs]) {
                column_delta = column_delta_abs;
                break;
            }

            if (!columns[current - column_delta_abs]) {
                column_delta = -column_delta_abs;
                break;
            }

            column_delta_abs++;
        }

        columns[current + column_delta] = true;
        return current + column_delta;
    }

    function add_commit_node(x, y, commit) {
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
            added = {},
            commits = [ history[Object.keys(history)[0]] ];

        while (commits.length) {
            commit = commits.shift();

            commit.parents.forEach(function(parent_sha1) {
                if (added[commit.sha1 + '->' + parent_sha1]) {
                    return;
                }

                added[commit.sha1 + '->' + parent_sha1] = true;
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
