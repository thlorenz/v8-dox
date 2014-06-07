#!/usr/bin/env node

'use strict';

var exec = require('child_process').exec;
var path = require('path');

// brittle, but nave has no main field, so resolve-bin fails
var nave = path.resolve(__dirname, '..', 'node_modules', '.bin', 'nave');
var acc = {};
var nodeVersions = [ '0.8', '0.10', '0.11']
var tasks = nodeVersions.length;

nodeVersions.forEach(function (v) {
  exec(nave + " use " + v + " node -e \"console.log('%s %s', process.versions.v8, process.versions.node)\"", function (err, stdout, stderr) {
    if (err) return console.error(err);

    var parts = stdout.trim('\n').split(' ');   

    // oddly enough node 0.8.26 reports a non existing v8 version 3.11.10.26
    var fixed = parts[0].split('.').slice(0, 3).join('.');
    acc[v] = { v8: fixed,  node: parts[1] };

    if (!--tasks) filter(acc);
  });
});

function filter(versions) {
  // versions are expected to be piped in ascending order
  process.stdin
    .on('data', ondata)
    .on('end', onend)

  var data = '';
  function ondata(d) { data += d.toString() }
  function onend() { 
    var previous;

    var allVersions = data.split('\n');

    Object.keys(versions)
      .forEach(function (k) {
        if (!~allVersions.indexOf(versions[k].v8)) throw new Error('Version ' + versions[k].v8 + ' not found!');
        process.stdout.write(versions[k].v8 + '\t\n' + versions[k].node + '\t\n')    
      })
  }
}
