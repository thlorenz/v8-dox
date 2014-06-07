#!/usr/bin/env node

'use strict';

// versions are expected to be piped in ascending order
process.stdin
  .on('data', ondata)
  .on('end', onend)

var data = '';
function ondata(d) { data += d.toString() }
function onend() { 
  var previous;

  data.split('\n')
    .reduce(function (acc, v) {
      var parts = v.split('.');
      if (parts.length < 3) return acc;

      var major = parts[0], minor = parts[1], patch = parts[2];

      if (previous && (previous.major < major || previous.minor < minor)) {
        acc.push(previous);
        previous = null;
      } 
      previous = { major: major, minor: minor, patch: patch };

      return acc;
    }, [])
    .forEach(function (v) {
      process.stdout.write(v.major + '.' + v.minor + '.' + v.patch + '\n')    
    })
}
