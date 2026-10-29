/// Demo data models for the BcDataTable showcase.
library demo_data;

class Person {
  final int id;
  final String name;
  final int age;
  final String email;
  final String department;
  final String role;
  final String status;

  const Person({
    required this.id,
    required this.name,
    required this.age,
    required this.email,
    required this.department,
    required this.role,
    required this.status,
  });

  static const List<Person> sample = [
    Person(id: 1, name: 'Alice Johnson', age: 32, email: 'alice@bitcode.io', department: 'Engineering', role: 'Admin', status: 'Active'),
    Person(id: 2, name: 'Bob Smith', age: 28, email: 'bob@bitcode.io', department: 'Design', role: 'Editor', status: 'Active'),
    Person(id: 3, name: 'Charlie Brown', age: 45, email: 'charlie@bitcode.io', department: 'Engineering', role: 'Viewer', status: 'Inactive'),
    Person(id: 4, name: 'Diana Prince', age: 35, email: 'diana@bitcode.io', department: 'Marketing', role: 'Editor', status: 'Active'),
    Person(id: 5, name: 'Evan Wright', age: 22, email: 'evan@bitcode.io', department: 'Sales', role: 'Viewer', status: 'Active'),
    Person(id: 6, name: 'Fiona Green', age: 29, email: 'fiona@bitcode.io', department: 'Engineering', role: 'Admin', status: 'Active'),
    Person(id: 7, name: 'George King', age: 41, email: 'george@bitcode.io', department: 'Operations', role: 'Editor', status: 'Inactive'),
    Person(id: 8, name: 'Hannah Lee', age: 26, email: 'hannah@bitcode.io', department: 'Design', role: 'Viewer', status: 'Active'),
  ];
}
