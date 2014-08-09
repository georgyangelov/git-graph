(function(window, document) {
    "use strict";

    var config = {
        strokeColor: '#000',
        strokeSize:  0.1,
        padding:     0.1,

        normalColor: '#fff',
        mergeColor:  '#e00',

        fontFamily: 'Arial',
        centerTextSize: 0.3,
        messageTextSize: 0.1,
        messageTextLineHeight: 1.3,
        sha1Cutoff: 7,

        detailsSize: 70
    };

    window.sigma.canvas.nodes.commit = function(node, context, settings) {
        var prefix  = settings('prefix') || '',
            size    = node[prefix + 'size'],
            x       = node[prefix + 'x'],
            y       = node[prefix + 'y'],
            width   = size * 2,
            height  = size,
            padding = config.padding * size;

        context.fillStyle = config.normalColor;
        context.strokeStyle = config.strokeColor;
        context.setLineWidth(config.strokeSize * size);

        if (size < config.detailsSize) {
            small_box();
        } else {
            big_box();
        }

        function small_box() {
            if (node.data.parents.length > 1) {
                context.fillStyle = config.mergeColor;
            }

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

            text_field([node.data.sha1.substring(0, config.sha1Cutoff)], config.centerTextSize * size, x, y, width - padding * 2);
        }

        function big_box() {
            if (node.data.parents.length > 1) {
                context.strokeStyle = config.mergeColor;
            }

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

            if (!node.fragmentMessage) {
                node.fragmentMessage = fragmentText(node.data.message, width - padding * 2);
            }

            text_field(node.fragmentMessage, config.messageTextSize * size, x, y, width - padding * 2);
        }

        function text_field(lines, size, x, y, w) {
            context.font = size + 'pt ' + config.fontFamily;
            context.fillStyle = '#000';
            context.textAlign = 'center';

            var height = lines.length * size * config.messageTextLineHeight;

            lines.forEach(function(line, i) {
                context.fillText(line, x, y - height / 2 + (i + 1) * size * config.messageTextLineHeight);
            });
        }

        // http://stackoverflow.com/questions/2936112/text-wrap-in-a-canvas-element
        function fragmentText(text, maxWidth) {
            var words = text.split(' '),
                lines = [],
                line = "";

            if (context.measureText(text).width < maxWidth) {
                return [text];
            }

            while (words.length > 0) {
                var split = false;

                while (context.measureText(words[0]).width >= maxWidth) {
                    var tmp = words[0];
                    words[0] = tmp.slice(0, -1);

                    if (!split) {
                        split = true;
                        words.splice(1, 0, tmp.slice(-1));
                    } else {
                        words[1] = tmp.slice(-1) + words[1];
                    }
                }

                if (context.measureText(line + words[0]).width < maxWidth) {
                    line += words.shift() + " ";
                } else {
                    lines.push(line);
                    line = "";
                }

                if (words.length === 0) {
                    lines.push(line);
                }
            }

            return lines;
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