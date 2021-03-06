require.config({
    shim: {
        'bootstrap': ['jquery'],
        'sparkline': ['jquery'],
        'tablesorter': ['jquery'],
        'vector-map': ['jquery'],
        'vector-map-de': ['vector-map', 'jquery'],
        'vector-map-world': ['vector-map', 'jquery'],
        'core': ['bootstrap', 'jquery'],
    },
    paths: {
        'core': '/js/core',
        'jquery': '/js/vendors/jquery-3.2.1.min',
        'bootstrap': '/js/vendors/bootstrap.bundle.min',
        'sparkline': '/js/vendors/jquery.sparkline.min',
        'selectize': '/js/vendors/selectize.min',
        'tablesorter': '/js/vendors/jquery.tablesorter.min',
        'vector-map': '/js/vendors/jquery-jvectormap-2.0.3.min',
        'vector-map-de': '/js/vendors/jquery-jvectormap-de-merc',
        'vector-map-world': '/js/vendors/jquery-jvectormap-world-mill',
        'circle-progress': '/js/vendors/circle-progress.min',
    }
});

// window.tabler = {
//     colors: {
//         {% for color in site.colors %}
//         '{{ color[0] }}': '{{ color[1].hex }}',
//         '{{ color[0] }}-darkest': '{{ color[1].hex | mix: "#000000", 20  }}',
//         '{{ color[0] }}-darker': '{{ color[1].hex | mix: "#000000", 40  }}',
//         '{{ color[0] }}-dark': '{{ color[1].hex | mix: "#000000", 80  }}',
//         '{{ color[0] }}-light': '{{ color[1].hex | mix: "#ffffff", 70 }}',
//         '{{ color[0] }}-lighter': '{{ color[1].hex | mix: "#ffffff", 30 }}',
//         '{{ color[0] }}-lightest': '{{ color[1].hex | mix: "#ffffff", 10 }}'{% unless forloop.last %},{% endunless %}{% endfor %}
//     }
// };

require(['core']);