
const Map<String, String> categoryImages = {
  'Beverages':     'assets/images/bev_pic.png',
  'Groceries':     'assets/images/groc_pic.png',
  'Bakery':        'assets/images/bak_pic.png',
  'Dairy':         'assets/images/dairy_pic.png',
  'Household':     'assets/images/hh_pic.png',
  'Personal Care': 'assets/images/pcare_pic.png',
  'Electronics':   'assets/images/elec_pic.png',
  'Other':         'assets/images/rand_pic.png',
};
String imageForCategory(String category) {
  return categoryImages[category] ?? 'assets/images/rand_pic.png';
}