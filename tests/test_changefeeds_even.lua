r = require('rethinkdb')

r.connect({timeout = 1}, function(err, c)
  r.db('changefeeds'):table('watched'):changes():filter(
    function(row)
      return (row('new_val')('id') % 2):eq(0)
    end
  ):limit(2):run(
    c, function(err, cur)
      if err then error(err.message) end
      r.db('changefeeds'):table('watched'):insert(
        {{id = 7}, {id = 8}, {id = 9}, {id = 10}}
      ):run(c)
      res = {}
      cur:each(function(err, row)
        if err then error(err.message) end
        table.insert(res, row.new_val.id)
      end)
      table.sort(res)
      local s = "{"
      local sep = ""
      for _, e in ipairs(res) do
        s = s .. sep .. e
        sep = ", "
      end
      print(s .. "}")
    end
  )
end)
