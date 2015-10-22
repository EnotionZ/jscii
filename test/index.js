#!/usr/bin/env node

var url = require('url');
var path = require('path');
var fs = require('fs');

var test = require('tape');
var express = require('express');
var Nightmare = require('nightmare');

var app = express();
app.use(express.static(path.join(__dirname, '..')));
var server = app.listen(0);
var nightmare = Nightmare();
nightmare
    .goto(url.format({
        protocol: 'http',
        hostname: 'localhost',
        port: server.address().port
    }))
    .then(function () {
        test("jscii", function (t) {
            t.test("encodes a jpg correctly", function (st) {
                st.plan(1);

                var selector = '#ascii-container-image';

                nightmare
                    .wait(selector)
                    .evaluate(function (selector) {
                        return document.querySelector(selector).innerText;
                    }, selector)
                    .then(function (text) {
                        st.equal(trim(text), trim(fs.readFileSync('test/fixtures/image.jpg.out', 'utf8')));
                    });
            });
            t.on('end', function () {
                nightmare
                    .end()
                    .then(function () { server.close(); }); // .then() is required or nightmare never closes
            });
        });
    });

trim.surroundingWhitespaceRegex = /^\s+|\s+$/g;
function trim (str) {
    return str.replace(trim.surroundingWhitespaceRegex, '');
}
