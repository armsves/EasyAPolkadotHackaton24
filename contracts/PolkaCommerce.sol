// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OnlineStore {
    address public admin;
    uint256 public categoryCount = 0;
    uint256 public productCount = 0;

    struct Category {
        uint256 id;
        string name;
        bool isActive;
    }

    struct Product {
        uint256 id;
        uint256 categoryId;
        string name;
        uint256 price; // in wei
        uint256 stock;
        bool isActive;
    }

    mapping(uint256 => Category) public categories;
    mapping(uint256 => Product) public products;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender; // Set the deployer as the admin
    }

    function addCategory(string memory _name) public onlyAdmin {
        categoryCount++;
        categories[categoryCount] = Category(categoryCount, _name, true);
    }

    function updateCategory(uint256 _id, string memory _name, bool _isActive) public onlyAdmin {
        require(_id <= categoryCount, "Category does not exist");
        categories[_id].name = _name;
        categories[_id].isActive = _isActive;
    }

    function deleteCategory(uint256 _id) public onlyAdmin {
        require(_id <= categoryCount, "Category does not exist");
        delete categories[_id];
    }

    function addProduct(uint256 _categoryId, string memory _name, uint256 _price, uint256 _stock) public onlyAdmin {
        require(_categoryId <= categoryCount, "Category does not exist");
        productCount++;
        products[productCount] = Product(productCount, _categoryId, _name, _price, _stock, true);
    }

    function updateProduct(uint256 _id, uint256 _categoryId, string memory _name, uint256 _price, uint256 _stock, bool _isActive) public onlyAdmin {
        require(_id <= productCount, "Product does not exist");
        require(_categoryId <= categoryCount, "Category does not exist");
        products[_id] = Product(_id, _categoryId, _name, _price, _stock, _isActive);
    }

    function deleteProduct(uint256 _id) public onlyAdmin {
        require(_id <= productCount, "Product does not exist");
        delete products[_id];
    }

    function getCategory(uint256 _id) public view returns (Category memory) {
        require(_id <= categoryCount, "Category does not exist");
        return categories[_id];
    }

    function getProduct(uint256 _id) public view returns (Product memory) {
        require(_id <= productCount, "Product does not exist");
        return products[_id];
    }

    function buyProduct(uint256 _id, uint256 _quantity) public payable {
        require(_id <= productCount, "Product does not exist");
        Product storage product = products[_id];
        require(product.isActive, "Product is not available");
        require(product.stock >= _quantity, "Insufficient stock");
        uint256 totalPrice = product.price * _quantity;
        require(msg.value >= totalPrice, "Insufficient funds sent");
        product.stock -= _quantity;
        // Transfer funds to admin or store's wallet
        payable(admin).transfer(totalPrice);
        // Refund any excess funds sent
        if (msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }
        // Emit an event for the purchase (event not defined in this snippet)
    }

    // Additional functions and events can be added as per requirements.
}