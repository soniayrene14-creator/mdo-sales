class DatabaseConfig {
  // Prevents instantiation and extension
  DatabaseConfig._();

  static const String dbPath = 'app_database.db';
  static const int version = 1;

  static const String userTableName = 'User';
  static const String productTableName = 'Product';
  static const String transactionTableName = 'Transaction';
  static const String orderedProductTableName = 'OrderedProduct';
  static const String queuedActionTableName = 'QueuedAction';

  static const String createUserTable =
      '''
CREATE TABLE IF NOT EXISTS '$userTableName' (
    'id' TEXT NOT NULL,
    'email' TEXT,
    'phone' TEXT,
    'name' TEXT,
    'gender' TEXT,
    'birthdate' TEXT,
    'imageUrl' TEXT,
    'authProvider' TEXT,
    'createdAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    'updatedAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ('id')
);
''';

  static const String createProductTable =
      '''
CREATE TABLE IF NOT EXISTS '$productTableName' (
    'id' INTEGER NOT NULL,
    'createdById' TEXT,
    'name' TEXT,
    'imageUrl' TEXT,
    'image' TEXT,
    'stock' INTEGER,
    'quantity' INTEGER,
    'sold' INTEGER,
    'price' INTEGER,
    'description' TEXT,
    'reference' TEXT,
    'category' INTEGER,
    'category_name' TEXT,
    'low_stock_threshold' INTEGER,
    'stock_status' TEXT,
    'is_active' INTEGER,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ('id'),
    FOREIGN KEY ('createdById') REFERENCES 'User' ('id')
);
''';

  /// Columns added to '$productTableName' after its initial release.
  /// Applied as best-effort `ALTER TABLE` statements on existing installs,
  /// since `CREATE TABLE IF NOT EXISTS` alone won't add them retroactively.
  static const List<String> productTableMigrationColumns = [
    "ALTER TABLE '$productTableName' ADD COLUMN 'image' TEXT",
    "ALTER TABLE '$productTableName' ADD COLUMN 'quantity' INTEGER",
    "ALTER TABLE '$productTableName' ADD COLUMN 'reference' TEXT",
    "ALTER TABLE '$productTableName' ADD COLUMN 'category' INTEGER",
    "ALTER TABLE '$productTableName' ADD COLUMN 'category_name' TEXT",
    "ALTER TABLE '$productTableName' ADD COLUMN 'low_stock_threshold' INTEGER",
    "ALTER TABLE '$productTableName' ADD COLUMN 'stock_status' TEXT",
    "ALTER TABLE '$productTableName' ADD COLUMN 'is_active' INTEGER",
  ];

  /// Applied as best-effort `ALTER TABLE` statements on existing installs,
  /// same reasoning as [productTableMigrationColumns].
  static const List<String> transactionTableMigrationColumns = [
    "ALTER TABLE '$transactionTableName' ADD COLUMN 'customer_phone' TEXT",
  ];

  static const String createTransactionTable =
      '''
CREATE TABLE IF NOT EXISTS '$transactionTableName' (
    'id' INTEGER NOT NULL,
    'paymentMethod' TEXT,
    'customerName' TEXT,
    'customer_phone' TEXT,
    'description' TEXT,
    'createdById' TEXT,
    'receivedAmount' INTEGER,
    'returnAmount' INTEGER,
    'totalAmount' INTEGER,
    'totalOrderedProduct' INTEGER,
    'createdAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    'updatedAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ('id'),
    FOREIGN KEY ('createdById') REFERENCES 'User' ('id')
);
''';

  static const String createOrderedProductTable =
      '''
CREATE TABLE IF NOT EXISTS '$orderedProductTableName' (
    'id' INTEGER NOT NULL,
    'transactionId' INTEGER,
    'productId' INTEGER,
    'quantity' INTEGER,
    'stock' INTEGER,
    'name' TEXT,
    'imageUrl' TEXT,
    'price' INTEGER,
    'createdAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    'updatedAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ('id'),
    FOREIGN KEY ('transactionId') REFERENCES 'Transaction' ('id'),
    FOREIGN KEY ('productId') REFERENCES 'Product' ('id')
);
''';

  static const String createQueuedActionTable =
      '''
CREATE TABLE IF NOT EXISTS '$queuedActionTableName' (
    'id' INTEGER NOT NULL,
    'repository' TEXT,
    'method' TEXT,
    'param' TEXT,
    'isCritical' INTEGER,
    'createdAt' DATETIME DEFAULT CURRENT_TIMESTAMP
);
''';
}
