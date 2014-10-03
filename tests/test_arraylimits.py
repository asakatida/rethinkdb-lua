import util


class TestArrayLimits(util.LuaTestCase):
    def setUp(self):
        self.create_table('array.limits')

    def test_create(self):
        self.assertEqual(self.run_lua('test_arraylimits_create'), "err(RqlRuntimeError, Array over size limit `4`., [0])")

    def test_equal(self):
        self.assertEqual(self.run_lua('test_arraylimits_equal'), "{1, 2, 3, 4, 5, 6, 7, 8}")

    def test_huge(self):
        self.assertEqual(self.run_lua('test_arraylimits_huge'), "100001")

    def test_huge_read(self):
        self.assertEqual(self.run_lua('test_arraylimits_huge_read'), "{'deleted':0.0,'replaced':0.0,'unchanged':0.0,'errors':1.0,'skipped':0.0,'inserted':1,'first_error':Array too large for disk writes (limit 100,000 elements)}")

    def test_huge_table(self):
        self.assertEqual(self.run_lua('test_arraylimits_huge_table'), "{'deleted':0.0,'replaced':0.0,'unchanged':0.0,'errors':1.0,'skipped':0.0,'inserted':1,'first_error':Array too large for disk writes (limit 100,000 elements)}")

    def test_lessthan(self):
        self.assertEqual(self.run_lua('test_arraylimits_lessthan'), "err(RqlRuntimeError, Array over size limit `4`., [0])")

    def test_lessthan_read(self):
        self.assertEqual(self.run_lua('test_arraylimits_lessthan_read'), "{'array':[1,2,3,4,5,6,7,8,9,10],'id':1}")

    def test_negative(self):
        self.assertEqual(self.run_lua('test_arraylimits_negative'), "err(RqlCompileError, Illegal array size limit `-1`., [])")

    def test_zero(self):
        self.assertEqual(self.run_lua('test_arraylimits_zero'), "err(RqlCompileError, Illegal array size limit `0`., [])")


if __name__ == '__main__':
    unittest.main()
