import UIKit
import Foundation

struct Todo: Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

struct Post: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
    
enum FetchError: Error {
    case invalidURL
    case noResponse
    case http(Int)
}

func fetchTodo(id: String) async throws -> Todo {
    print("start todo\(id): \(Date())")
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos/\(id)") else {
        throw FetchError.invalidURL
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    let todo = try JSONDecoder().decode(Todo.self, from: data)
    print("end todo\(id): \(Date())")
    return todo
}

func fetchPosts() async throws -> [Post] {
    print("start post: \(Date())")
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
        throw FetchError.invalidURL
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    let posts = try JSONDecoder().decode([Post].self, from: data)
    print("end post: \(Date())")
    return posts
}

func makePreRequests() async throws -> (Todo, Todo, [Post]) {

    // Using Task to run todoTask1 & todoTask2 parallel
    let todoTask1 = Task(priority: .background) {
      try await fetchTodo(id: "1")
    }

    let todoTask2 = Task(priority: .background) {
      try await fetchTodo(id: "2")
    }
    
    let posts = try await fetchPosts()
    
    // todo3 will start after getting posts.
    let todo3 = try await fetchTodo(id: "3")
    let todo1 = try await todoTask1.value
    let todo2 = try await todoTask2.value
    
    return (todo1, todo2, posts)
}

Task(priority: .background) {
    let result = try? await makePreRequests()
    print("xxx \(result?.2.count)")
}
print("done")

// output:
//done
//start post: 2023-06-27 16:00:55 +0000
//start todo1: 2023-06-27 16:00:55 +0000
//start todo2: 2023-06-27 16:00:55 +0000
//end todo1: 2023-06-27 16:00:55 +0000
//end todo2: 2023-06-27 16:00:55 +0000
//end post: 2023-06-27 16:00:55 +0000
//start todo3: 2023-06-27 16:00:56 +0000
//end todo3: 2023-06-27 16:00:56 +0000
//xxx Optional(100)
