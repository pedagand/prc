/* Standard math functions */

function plus(a, b) {
    return a + b;
}

function minus(a, b) {
    return a - b;
}

function uminus(a) {
    return -a;
}

function times(a, b) {
    return a * b;
}

function div(a, b) {
    return a / b;
}

/* Boolean ops */

function or(a, b) {
    return a || b;
}

function and(a, b) {
    return a && b;
}

function not(a) {
    return !a;
}

/* Comparison ops */

function greater_than(a, b) {
    return a > b;
}

function egreater_than(a, b) {
    return a >= b;
}

function less_than(a, b) {
    return a < b;
}

function e_less_than(a, b) {
    return a <= b;
}

function equals(a, b) {
    return a === b;
}

/* Sine functions */

function cos(a) {
    return Math.cos(a);
}

function sin(a) {
    return Math.sin(a);
}

function tan(a) {
    return Math.tan(a);
}
var canvas = document.getElementById("canvas");
var ctx = canvas.getContext("2d");

function draw_rect(x, y, w, h) {
    ctx.beginPath();
    ctx.rect(x, y, w, h);
    ctx.fillStyle = "#0095DD";
    ctx.fill();
    ctx.closePath();
}
