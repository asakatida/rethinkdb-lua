local function reql_error_formatter(err)
  if type(err) ~= 'table' then return end
  if err.ReQLError then
    return err.message()
  end
end

describe('array limits', function()
  local r, reql_table, c, huge_l

  setup(function()
    assert:add_formatter(reql_error_formatter)
    r = require('rethinkdb')

    local reql_db = 'array'
    reql_table = 'limits'

    local ten_l = r.reql{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    local function ten_f() return ten_l end
    huge_l = ten_l.concat_map(ten_f).concat_map(ten_f).concat_map(
      ten_f).concat_map(ten_f)

    local err

    c, err = r.connect{proto_version = r.proto_V0_4}
    assert.is_nil(err)

    r.reql.db_create(reql_db).run(c)
    c.use(reql_db)
    r.reql.table_create(reql_table).run(c)
  end)

  teardown(function()
    r.reql.table(reql_table).delete().run(c)
    c.close()
    c = nil
    r = nil
    assert:remove_formatter(reql_error_formatter)
  end)

  it('create', function()
    r{1, 2, 3, 4, 5, 6, 7, 8}.run(
      c, {array_limit = 4}, function(_err, cur)
        assert.is_nil(_err)
        cur.to_array(function(err, arr)
          assert.is_nil(arr)
          assert.is_not_nil(err)
        end)
      end
    )
  end)

  it('equal', function()
    assert.same({{1, 2, 3, 4, 5, 6, 7, 8}}, r.reql{1, 2, 3, 4}.union{5, 6, 7, 8}.run(
      c, {array_limit = 8}, function(_err, cur)
        assert.is_nil(_err)
        return cur.to_array(function(err, arr)
          assert.is_nil(err)
          return arr
        end)
      end
    ))
  end)

  it('huge', function()
    assert.same({100001}, huge_l.append(1).count().run(
      c, {array_limit = 100001}, function(_err, cur)
        assert.is_nil(_err)
        return cur.to_array(function(err, arr)
          assert.is_nil(err)
          return arr
        end)
      end
    ))
  end)

  it('huge read', function()
    r.reql.table(reql_table).insert{id = 0, array = huge_l.append(1)}.run(
      c, {array_limit = 100001}, function(_err, cur)
        assert.is_nil(_err)
        return cur.to_array(function(err, arr)
          assert.is_nil(err)
          return arr
        end)
      end
    )
    assert.same(
      {}, r.reql.table(reql_table).get(0).run(
        c, {array_limit = 100001}, function(_err, cur)
          assert.is_nil(_err)
          return cur.to_array(function(err, arr)
            assert.is_nil(err)
            return arr
          end)
        end
      )
    )
  end)

  it('huge table', function()
    assert.same(
      {{
        deleted = 0, unchanged = 0, replaced = 0, skipped = 0,
        errors = 1, inserted = 0,
        first_error =
        'Array too large for disk writes (limit 100,000 elements).'
      }},
      r.reql.table(reql_table).insert{id = 0, array = huge_l.append(1)}.run(
        c, {array_limit = 100001}, function(_err, cur)
          assert.is_nil(_err)
          return cur.to_array(function(err, arr)
            assert.is_nil(err)
            return arr
          end)
        end
      )
    )
  end)
  it('less than', function()
    r.reql{1, 2, 3, 4}.union{5, 6, 7, 8}.run(
      c, {array_limit = 4}, function(_err, cur)
        assert.is_nil(_err)
        cur.to_array(function(err, arr)
          assert.is_nil(arr)
          assert.is_not_nil(err)
        end)
      end
    )
  end)

  it('less than read', function()
    r.reql.table(reql_table).insert(
      {id = 1, array = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}}
    ).run(
      c, function(_err, cur)
        assert.is_nil(_err)
        return cur.to_array(function(err, arr)
          assert.is_nil(err)
          return arr
        end)
      end
    )
    assert.same(
      {{array = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, id = 1}},
      r.reql.table(reql_table).get(1).run(
        c, {array_limit = 4}, function(_err, cur)
          assert.is_nil(_err)
          return cur.to_array(function(err, arr)
            assert.is_nil(err)
            return arr
          end)
        end
      )
    )
  end)

  it('negative', function()
    r.reql{1, 2, 3, 4, 5, 6, 7, 8}.run(
      c, {array_limit = -1}, function(_err, cur)
        assert.is_nil(_err)
        cur.to_array(function(err, arr)
          assert.is_nil(arr)
          assert.is_not_nil(err)
        end)
      end
    )
  end)

  it('zero', function()
    r.reql{1, 2, 3, 4, 5, 6, 7, 8}.run(
      c, {array_limit = 0}, function(_err, cur)
        assert.is_nil(_err)
        cur.to_array(function(err, arr)
          assert.is_nil(arr)
          assert.is_not_nil(err)
        end)
      end
    )
  end)
end)
