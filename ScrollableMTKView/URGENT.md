# URGENT

- 刚刚打开app使用的内存是60MB 但是一打开Control Center再放回去就变成120MB了
    - control+center+effect+metal+performance
    - loadView里面到底什么东西增多了？引用没释放？RenderView还是用的原来的？感觉像是重新addSubView了
    - 如何让View重新加载
