importScripts('https://cdn.jsdelivr.net/npm/sql.js@1.10.3/dist/sql-wasm.wasm');
importScripts('https://cdn.jsdelivr.net/npm/sql.js@1.10.3/dist/sql-wasm.js');

const dbMap = new Map();

self.onmessage = function(e) {
  const { id, action, dbName, sql, params } = e.data;
  
  try {
    switch (action) {
      case 'open':
        if (!dbMap.has(dbName)) {
          const db = new SQL.Database();
          dbMap.set(dbName, db);
        }
        self.postMessage({ id, result: 'ok' });
        break;
        
      case 'execute':
        const db = dbMap.get(dbName);
        if (!db) {
          throw new Error(`Database ${dbName} not open`);
        }
        
        const result = db.exec(sql, params ? [params] : []);
        self.postMessage({ id, result });
        break;
        
      case 'close':
        dbMap.delete(dbName);
        self.postMessage({ id, result: 'ok' });
        break;
        
      default:
        throw new Error(`Unknown action: ${action}`);
    }
  } catch (error) {
    self.postMessage({ id, error: error.message });
  }
};