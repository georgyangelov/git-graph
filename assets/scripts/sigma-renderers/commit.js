(function(window, document) {
    "use strict";

    var config = {
        strokeColor: '#000',
        strokeSize:  0.1,
        fillColor:   '#fff',
        padding: 0.1,

        fontFamily: 'Arial',
        centerTextSize: 0.3,
        sha1Cutoff: 7
    };

    window.sigma.canvas.nodes.commit = function(node, context, settings) {
        var prefix  = settings('prefix') || '',
            size    = node[prefix + 'size'],
            x       = node[prefix + 'x'],
            y       = node[prefix + 'y'],
            width   = size * 2,
            height  = size,
            padding = config.padding * size;

        context.fillStyle = config.fillColor;

        context.strokeStyle = config.strokeColor;
        context.setLineWidth(config.strokeSize * size);

        box();
        text_field(node.data.sha1, x, y, width - padding * 2);

        function box() {
            context.beginPath();
            context.rect(
                x - width / 2,
                y - height / 2,
                width,
                height
            );
            context.closePath();

            context.stroke();
            context.fill();
        }

        function text_field(text, x, y, w) {
            context.font = (config.centerTextSize * size) + 'pt ' + config.fontFamily;
            context.fillStyle = '#000';
            context.textAlign = 'center';
            context.textBaseline = 'middle';

            context.fillText(text.substring(0, config.sha1Cutoff), x, y);
        }
    };

    function fit_string(context, string, max_width) {
        var width = context.measureText(string).width;
        var ellipsis = '…';
        var ellipsis_width = context.measureText(ellipsis).width;

        if (width <= max_width || width <= ellipsis_width) {
            return string;
        }

        var length = string.length;

        while (width >= max_width - ellipsis_width && length-- > 0) {
            string = string.substring(0, length);
            width = context.measureText(string).width;
        }

        return string + ellipsis;
    }

})(window, document);