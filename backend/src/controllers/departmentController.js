// Department & Category Master Data Controller
const { getStore } = require('../services/localStore');

// GET /api/v1/departments
async function listDepartments(req, res) {
  const store = getStore();
  const departmentsWithCategories = store.departments.map(dept => {
    const cats = store.categories.filter(c => c.department_id === dept.id);
    return {
      ...dept,
      categories: cats
    };
  });

  return res.success(departmentsWithCategories, 'Departments retrieved successfully');
}

// GET /api/v1/departments/categories
async function listCategories(req, res) {
  const store = getStore();
  const { departmentId } = req.query;

  let categories = store.categories;
  if (departmentId) {
    categories = categories.filter(c => c.department_id === departmentId);
  }

  return res.success(categories, 'Categories retrieved');
}

module.exports = {
  listDepartments,
  listCategories
};
