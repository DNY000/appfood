import 'package:flutter/material.dart';
import 'package:foodapp/common_widget/show_loading.dart';

class TRefreshData<T> extends StatefulWidget {
  final Future<List<T>> Function() onRefresh;
  final Widget Function(List<T> data) builder;
  final Widget? loadingData;

  const TRefreshData({
    super.key,
    required this.onRefresh,
    required this.builder,
    this.loadingData,
  });

  @override
  State<TRefreshData<T>> createState() => _TRefreshDataState<T>();
}

class _TRefreshDataState<T> extends State<TRefreshData<T>> {
  List<T>? data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      LoadingUtil.show();
      final result = await widget.onRefresh();
      setState(() => data = result);
    } catch (e) {
      debugPrint('Loading fail: $e');
    } finally {
      LoadingUtil.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return widget.loadingData ?? const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: widget.builder(data!),
    );
  }
}


class LoadMoreRefreshIndicator<T> extends StatefulWidget {
  final Future<List<T>> Function() onRefresh;
  final Future<List<T>> Function(int page) onLoadMore;
    final Widget Function(List<T> data) builder;
    final Widget? loadingWidget;
    final Widget? emptyWidget;
  /// Ngưỡng để trigger load more (0.0 - 1.0)
  final double loadMoreThreshold;

  const LoadMoreRefreshIndicator({
    Key? key,
    required this.onRefresh,
    required this.onLoadMore,
    required this.builder,
    this.loadingWidget,
    this.emptyWidget,
    this.loadMoreThreshold = 0.8, // Trigger khi cuộn 80%
  }) : super(key: key);

  @override
  State<LoadMoreRefreshIndicator<T>> createState() => _LoadMoreRefreshIndicatorState<T>();
}

class _LoadMoreRefreshIndicatorState<T> extends State<LoadMoreRefreshIndicator<T>> {
  List<T> _data = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _error;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  bool _onScrollNotification(ScrollNotification notification) {
    // Chỉ xử lý ScrollUpdateNotification
    if (notification is ScrollUpdateNotification) {
      final double progress = notification.metrics.pixels / notification.metrics.maxScrollExtent;
      
      // Nếu cuộn đến ngưỡng và chưa đang load more
      if (progress >= widget.loadMoreThreshold && 
          !_isLoadingMore && 
          _hasMoreData && 
          notification.metrics.pixels > 0) {
        _loadMoreData();
      }
    }
    
    return false; // Không chặn notification
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
      });
      
      final newData = await widget.onRefresh();
      
      setState(() {
        _data = newData;
        _isLoading = false;
        _hasMoreData = newData.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    try {
      setState(() {
        _isLoadingMore = true;
      });
      
      _currentPage++;
      final moreData = await widget.onLoadMore(_currentPage);
      
      setState(() {
        if (moreData.isNotEmpty) {
          _data.addAll(moreData);
        } else {
          _hasMoreData = false;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _currentPage--; 
      });
            if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi load more: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ?? 
        const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Có lỗi xảy ra: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    if (_data.isEmpty) {
      return widget.emptyWidget ?? 
        const Center(child: Text('Không có dữ liệu'));
    }

    // Hiển thị dữ liệu với RefreshIndicator và NotificationListener
    return RefreshIndicator(
      onRefresh: _loadData,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: Column(
          children: [
            Expanded(
              child: widget.builder(_data),
            ),
            if (_isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Đang tải thêm...'),
                  ],
                ),
              ),
            if (!_hasMoreData && _data.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Đã tải hết dữ liệu',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Helper class cho ListView với NotificationListener
class LoadMoreListView<T> extends StatelessWidget {
  final Future<List<T>> Function() onRefresh;
  final Future<List<T>> Function(int page) onLoadMore;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final EdgeInsetsGeometry? padding;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final double loadMoreThreshold;

  const LoadMoreListView({
    Key? key,
    required this.onRefresh,
    required this.onLoadMore,
    required this.itemBuilder,
    this.separatorBuilder,
    this.padding,
    this.loadingWidget,
    this.emptyWidget,
    this.loadMoreThreshold = 0.8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoadMoreRefreshIndicator<T>(
      onRefresh: onRefresh,
      onLoadMore: onLoadMore,
      loadingWidget: loadingWidget,
      emptyWidget: emptyWidget,
      loadMoreThreshold: loadMoreThreshold,
      builder: (data) => ListView.separated(
        padding: padding,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, index) => itemBuilder(context, data[index], index),
        separatorBuilder: separatorBuilder ?? (context, index) => const Divider(),
      ),
    );
  }
}

// Helper class cho GridView với NotificationListener
class LoadMoreGridView<T> extends StatelessWidget {
  final Future<List<T>> Function() onRefresh;
  final Future<List<T>> Function(int page) onLoadMore;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final SliverGridDelegate gridDelegate;
  final EdgeInsetsGeometry? padding;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final double loadMoreThreshold;

  const LoadMoreGridView({
    Key? key,
    required this.onRefresh,
    required this.onLoadMore,
    required this.itemBuilder,
    required this.gridDelegate,
    this.padding,
    this.loadingWidget,
    this.emptyWidget,
    this.loadMoreThreshold = 0.8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoadMoreRefreshIndicator<T>(
      onRefresh: onRefresh,
      onLoadMore: onLoadMore,
      loadingWidget: loadingWidget,
      emptyWidget: emptyWidget,
      loadMoreThreshold: loadMoreThreshold,
      builder: (data) => GridView.builder(
        padding: padding,
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: gridDelegate,
        itemCount: data.length,
        itemBuilder: (context, index) => itemBuilder(context, data[index], index),
      ),
    );
  }
}

// Ví dụ sử dụng với ListView
class ListViewExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ListView với NotificationListener')),
      body: LoadMoreListView<String>(
        loadMoreThreshold: 0.7, // Trigger khi cuộn 70%
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          return List.generate(20, (index) => 'Item ${index + 1}');
        },
        onLoadMore: (page) async {
          await Future.delayed(const Duration(seconds: 1));
          if (page > 5) return [];
          
          final startIndex = (page - 1) * 20;
          return List.generate(20, (index) => 'Item ${startIndex + index + 1}');
        },
        itemBuilder: (context, item, index) {
          return Card(
            child: ListTile(
              title: Text(item),
              subtitle: Text('Global Index: $index'),
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GridViewExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GridView với NotificationListener')),
      body: LoadMoreGridView<String>(
        loadMoreThreshold: 0.9, // Trigger khi cuộn 90%
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        padding: const EdgeInsets.all(16),
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          return List.generate(20, (index) => 'Product ${index + 1}');
        },
        onLoadMore: (page) async {
          await Future.delayed(const Duration(seconds: 1));
          if (page > 3) return [];
          
          final startIndex = (page - 1) * 20;
          return List.generate(20, (index) => 'Product ${startIndex + index + 1}');
        },
        itemBuilder: (context, item, index) {
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag, size: 48, color: Colors.blue),
                const SizedBox(height: 8),
                Text(item, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Index: $index'),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Ví dụ với custom ScrollView
class CustomScrollViewExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom ScrollView')),
      body: LoadMoreRefreshIndicator<String>(
        loadMoreThreshold: 0.85,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          return List.generate(10, (index) => 'Section ${index + 1}');
        },
        onLoadMore: (page) async {
          await Future.delayed(const Duration(seconds: 1));
          if (page > 4) return [];
          
          final startIndex = (page - 1) * 10;
          return List.generate(10, (index) => 'Section ${startIndex + index + 1}');
        },
        builder: (data) => CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ExpansionTile(
                    title: Text(data[index]),
                    children: [
                      ListTile(
                        title: Text('Content of ${data[index]}'),
                        subtitle: Text('This is expandable content'),
                      ),
                    ],
                  ),
                ),
                childCount: data.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Demo page với tất cả ví dụ
class DemoPage extends StatefulWidget {
  @override
  _DemoPageState createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ListViewExample(),
    GridViewExample(),
    CustomScrollViewExample(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'ListView',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'GridView',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'CustomScrollView',
          ),
        ],
      ),
    );
  }
}