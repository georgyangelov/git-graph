(function(window, document) {
    "use strict";

    var config = {
        color: '#000',
        width: 1
    };

    window.sigma.canvas.edges.def = function(edge, source, target, context, settings) {
        var prefix = settings('prefix') || '',
            size   = edge[prefix + 'size'] || 1;

        if (source[prefix + 'y'] > target[prefix + 'y']) {
            context.strokeStyle = '#f00';
        } else {
            context.strokeStyle = config.color;
        }

        context.lineWidth = size * config.width;

        context.beginPath();
        context.moveTo(
          source[prefix + 'x'],
          source[prefix + 'y']
        );
        context.lineTo(
          target[prefix + 'x'],
          target[prefix + 'y']
        );
        context.closePath();

        context.stroke();
    };

})(window, document);