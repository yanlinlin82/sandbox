// 测试方法：
// $ g++ benchmark-flat-set-20240115.cpp
// $ ./a.out
#include <set>
#include <vector>
#include <chrono>
#include <iostream>
#include <random>

#if __cplusplus < 202002L
#include <boost/container/flat_set.hpp>
namespace std {
	using boost::container::flat_set;
}
#endif

std::vector<int> generateRandomData(size_t size) {
	std::vector<int> data(size);
	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_int_distribution<> dis(1, 1000000);

	for (auto& d : data) {
		d = dis(gen);
	}
	return data;
}

template<typename SetType>
void printElementAddresses(const char* setName, const SetType& testSet) {
	int count = 0;
	std::cout << "Addresses of first five elements in '" << setName << "':\n";
	for (auto it = testSet.begin(); it != testSet.end() && count < 5; ++it, ++count) {
		std::cout << "  " << count << ": " << &(*it) << '\n';
	}
}

template<typename SetType>
void performTest(SetType& testSet, const std::vector<int>& data) {
	// 插入操作
	auto start = std::chrono::high_resolution_clock::now();
	for (const auto& d : data) {
		testSet.insert(d);
	}
	auto end = std::chrono::high_resolution_clock::now();
	std::cout << "Insert time: " << std::chrono::duration_cast<std::chrono::microseconds>(end - start).count() << " microseconds\n";

	// 查找操作
	start = std::chrono::high_resolution_clock::now();
	for (const auto& d : data) {
		testSet.find(d);
	}
	end = std::chrono::high_resolution_clock::now();
	std::cout << "Find time: " << std::chrono::duration_cast<std::chrono::microseconds>(end - start).count() << " microseconds\n";

	// 迭代操作
	start = std::chrono::high_resolution_clock::now();
	for (auto it = testSet.begin(); it != testSet.end(); ++it) {
		// 迭代器遍历
	}
	end = std::chrono::high_resolution_clock::now();
	std::cout << "Iteration time: " << std::chrono::duration_cast<std::chrono::microseconds>(end - start).count() << " microseconds\n";
}

int main() {
	const size_t TEST_SIZE = 1000000; // 调整测试数据的大小
	auto data = generateRandomData(TEST_SIZE); // 为公平比较，需确保处理相同的随机数据

	std::cout << "Testing flat_set...\n";
	std::flat_set<int> fs;
	performTest(fs, data);

	std::cout << "\nTesting std::set...\n";
	std::set<int> ss;
	performTest(ss, data);

	std::cout << std::endl;
	printElementAddresses("std::flat_set", fs);
	printElementAddresses("std::set", ss);

	return 0;
}
