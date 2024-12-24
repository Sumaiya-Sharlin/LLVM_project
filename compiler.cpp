#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>
#include <map>
#include <memory>
#include <cctype>
#include <stdexcept>

using namespace std;

// Token types
enum class TokenType {
    Identifier, Number, Operator, Keyword, Separator, EndOfFile
};

// Token structure
struct Token {
    TokenType type;
    string value;
};

// Lexer: Converts input code into tokens
class Lexer {
public:
    explicit Lexer(const string& input) : input(input), position(0) {}

    Token getNextToken() {
        while (position < input.size() && isspace(input[position])) {
            position++;
        }

        if (position >= input.size()) {
            return {TokenType::EndOfFile, ""};
        }

        char current = input[position];
        if (isalpha(current)) {
            string identifier;
            while (position < input.size() && (isalnum(input[position]) || input[position] == '_')) {
                identifier += input[position++];
            }
            if (identifier == "double" || identifier == "if" || identifier == "else" || identifier == "print") {
                return {TokenType::Keyword, identifier};
            }
            return {TokenType::Identifier, identifier};
        }

        if (isdigit(current) || current == '.') {
            string number;
            while (position < input.size() && (isdigit(input[position]) || input[position] == '.')) {
                number += input[position++];
            }
            return {TokenType::Number, number};
        }

        if (current == '+' || current == '-' || current == '*' || current == '/' || current == '=' ||
            current == '<' || current == '>') {
            position++;
            return {TokenType::Operator, string(1, current)};
        }

        if (current == '(' || current == ')' || current == '{' || current == '}' || current == ';') {
            position++;
            return {TokenType::Separator, string(1, current)};
        }

        throw runtime_error("Unknown character: " + string(1, current));
    }

private:
    string input;
    size_t position;
};

// Global variables map
map<string, double> globalVariables;

// AST nodes
struct ASTNode {
    virtual ~ASTNode() = default;
    virtual double evaluate() = 0;
};

struct NumberNode : ASTNode {
    double value;
    explicit NumberNode(double value) : value(value) {}
    double evaluate() override { return value; }
};

struct VariableNode : ASTNode {
    string name;
    explicit VariableNode(string name) : name(move(name)) {}
    double evaluate() override {
        if (globalVariables.find(name) == globalVariables.end()) {
            throw runtime_error("Undefined variable: " + name);
        }
        return globalVariables[name];
    }
};

struct BinaryOpNode : ASTNode {
    char op;
    shared_ptr<ASTNode> left, right;
    BinaryOpNode(char op, shared_ptr<ASTNode> left, shared_ptr<ASTNode> right)
        : op(op), left(move(left)), right(move(right)) {}

    double evaluate() override {
        double leftValue = left->evaluate();
        double rightValue = right->evaluate();
        switch (op) {
            case '+': return leftValue + rightValue;
            case '-': return leftValue - rightValue;
            case '*': return leftValue * rightValue;
            case '/': return leftValue / rightValue;
            case '<': return leftValue < rightValue;
            case '>': return leftValue > rightValue;
            default: throw runtime_error("Unknown operator: " + string(1, op));
        }
    }
};

// Parser: Builds an AST
class Parser {
public:
    explicit Parser(vector<Token> tokens) : tokens(move(tokens)), position(0) {}

    shared_ptr<ASTNode> parseExpression() {
        auto left = parsePrimary();
        while (position < tokens.size() && tokens[position].type == TokenType::Operator) {
            char op = tokens[position].value[0];
            position++;
            auto right = parsePrimary();
            left = make_shared<BinaryOpNode>(op, left, right);
        }
        return left;
    }

    shared_ptr<ASTNode> parsePrimary() {
        Token token = tokens[position++];
        if (token.type == TokenType::Number) {
            return make_shared<NumberNode>(stod(token.value));
        } else if (token.type == TokenType::Identifier) {
            return make_shared<VariableNode>(token.value);
        } else if (token.type == TokenType::Separator && token.value == "(") {
            auto expr = parseExpression();
            if (tokens[position++].value != ")") {
                throw runtime_error("Expected closing parenthesis");
            }
            return expr;
        }
        throw runtime_error("Unexpected token: " + token.value);
    }

    void parseAndExecute() {
        while (position < tokens.size() && tokens[position].type != TokenType::EndOfFile) {
            Token token = tokens[position++];
            if (token.type == TokenType::Keyword && token.value == "double") {
                string varName = tokens[position++].value;
                position++; // Skip '='
                auto expr = parseExpression();
                globalVariables[varName] = expr->evaluate();
            } else if (token.type == TokenType::Keyword && token.value == "if") {
                position++; // Skip '('
                auto condition = parseExpression();
                position++; // Skip ')'
                position++; // Skip '{'

                if (condition->evaluate()) {
                    parseStatement();
                } else {
                    skipBlock();
                    position++; // Skip "else"
                    position++; // Skip '{'
                    parseStatement();
                }
            } else if (token.type == TokenType::Keyword && token.value == "print") {
                position++; // Skip '('
                auto expr = parseExpression();
                position++; // Skip ')'
                cout << expr->evaluate() << endl;
            }
        }
    }

private:
    vector<Token> tokens;
    size_t position;

    void parseStatement() {
        if (tokens[position].type == TokenType::Identifier) {
            string varName = tokens[position++].value;
            position++; // Skip '='
            auto expr = parseExpression();
            globalVariables[varName] = expr->evaluate();
            position++; // Skip ';'
        }
    }

    void skipBlock() {
        int braceCount = 1;
        while (braceCount > 0) {
            if (tokens[position].value == "{") braceCount++;
            if (tokens[position].value == "}") braceCount--;
            position++;
        }
    }
};

int main() {
    ifstream inputFile("input.txt");
    if (!inputFile.is_open()) {
        cerr << "Error: Could not open input.txt" << endl;
        return 1;
    }

    stringstream buffer;
    buffer << inputFile.rdbuf();
    string input = buffer.str();
    inputFile.close();

    Lexer lexer(input);
    vector<Token> tokens;
    Token token = lexer.getNextToken();
    while (token.type != TokenType::EndOfFile) {
        tokens.push_back(token);
        token = lexer.getNextToken();
    }

    Parser parser(tokens);
    parser.parseAndExecute();

    return 0;
}

// Compile:

// g++ -o compiler compiler.cpp
// ./compiler

// input.txt
// double x = 10.5;
// double y = x + ((6 * 6) / 5);
// if (y > 0) {
//     y = y / 2.0;
// } 
// else {
//     y = 0.0;
// }
// print(y);