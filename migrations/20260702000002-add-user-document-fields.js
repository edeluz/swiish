'use strict';

var dbm;
var type;
var seed;

exports.setup = function(options, seedLink) {
  dbm = options.dbmigrate;
  type = dbm.dataType;
  seed = seedLink;
};

exports.up = function(db) {
  var filePath = require('path').join(__dirname, 'sqls', '20260702000002-add-user-document-fields-up.sql');
  return new Promise(function(resolve, reject) {
    require('fs').readFile(filePath, { encoding: 'utf-8' }, function(err, data) {
      if (err) return reject(err);
      // Run each statement separately (SQLite ALTER TABLE must be separate)
      var stmts = data.split(';').map(function(s) { return s.trim(); }).filter(Boolean);
      var run = function(i) {
        if (i >= stmts.length) return resolve();
        db.runSql(stmts[i] + ';', function(err) {
          if (err) return reject(err);
          run(i + 1);
        });
      };
      run(0);
    });
  });
};

exports.down = function(db) {
  var filePath = require('path').join(__dirname, 'sqls', '20260702000002-add-user-document-fields-down.sql');
  return new Promise(function(resolve, reject) {
    require('fs').readFile(filePath, { encoding: 'utf-8' }, function(err, data) {
      if (err) return reject(err);
      db.runSql(data, function(err) {
        if (err) return reject(err);
        resolve();
      });
    });
  });
};

exports._meta = {
  version: 1
};
