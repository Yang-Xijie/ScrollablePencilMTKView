# TODO

## URGENT

- 刚刚打开app使用的内存是60MB 但是一打开Control Center再放回去就变成120MB了
    - control+center+effect+metal+performance
    - loadView里面到底什么东西增多了？引用没释放？RenderView还是用的原来的？感觉像是重新addSubView了
    - 如何让View重新加载
    - [Fix for Control Center lag on iOS 9](https://forums.macrumors.com/threads/fix-for-control-center-lag-on-ios-9-2-1-and-possibly-9-2.1946042/) 
    - https://developer.apple.com/documentation/metal/performance_tuning/using_metal_system_trace_in_instruments_to_profile_your_app
    - [Apple Developer Forums | CAMetalLayer nextDrawable delay with Control Center](https://developer.apple.com/forums/thread/23798)
    - [GitHub | flutter/issues: Scrolling is not true 120hz and feels laggy on ProMotion iPhone 13](https://github.com/flutter/flutter/issues/90675)

## 优化

* 无需按照时间渲染，每次有东西改变的时候自动渲染或手动调用函数渲染
* 分割线的顶点可以共用
* mtkView以外的uiView进行缩略图渲染

## 贝塞尔曲线

* Nb上的一笔究竟是如何定义的？？是贝塞尔曲线直接围起来形成图形？还是把笔划的最中间的那条轨迹和每个轨迹点的粗度存起来？
    * 按照 https://stackoverflow.com/a/42891040/14298786 所说应该是中间点的轨迹
    * 如果是是贝塞尔曲线，那就Metal直接三角形绘制

## Apple Pencil

* 笔划的数据结构定义
* 笔划是怎么存储的
* 矢量是什么？字体如何渲染在屏幕上 How to show a vector on iOS screen
* 看一下PDF的标准，基本上和PDF一致吧

画一笔的过程：
* Pencil挨到屏幕，数据采集开始，收到第一个点，存储第一个点；
* Pencil开始滑动，收到第二个点；
* Pencil继续滑动，收到第三个点；
    * 如果第三个点离第二个点特别近，那么这个点不用记录
    * 如果第三个点与第二个点的连线 与 第一个点和第二点的连线的角度特别相似，那么这个点不用记录
    * 虽然说不用记录，但其实是不用存储第二个点，而是根据第二个点和第三个点的关系，存储第三个点附近的一个位置点。
    * 如果第三个点和前面的数据差的比较远，直接存储。
    * 注意这里说的都是位置，注意还要存储压力。
* Pencil继续滑动，收到第四个点；
    * 注意如果仍然按照上面的方法，第四个点是否存储取决于第四个点与 第二第三个点的关系。因此即使不存储第二第三个点，也应该在内存中留下
* Pencil离开屏幕，将存储的点真正进行存储
    * 注意之前步骤所说的存储是指，收集到的数据在一个数组，确定存储的数据在一个数组（小于收到的数据的数量）
    * 在Pencil完成一笔的时候，我们将确定存储的这些数据写入文件，完成一笔的绘制。

渲染过程：
* 差值为曲线即可
