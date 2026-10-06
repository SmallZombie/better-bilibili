
import 'package:flutter/material.dart';

void main() {
  runApp(const VideoEditorDemo());
}

class VideoEditorDemo extends StatelessWidget {
  const VideoEditorDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Video Editor',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF111111),
      ),
      home: const EditorPage(),
    );
  }
}

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  int _selectedTab = 0;
  int _selectedTool = 0;
  bool _playing = false;
  double _timelineProgress = 0.34;

  final List<String> _tabs = ['媒体', '音频', '文字', '贴纸', '效果'];
  final List<IconData> _toolIcons = [
    Icons.near_me_outlined,
    Icons.content_cut_outlined,
    Icons.crop_outlined,
    Icons.volume_up_outlined,
    Icons.speed_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTitleBar(),
            _buildToolbar(),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: _buildMediaPanel(),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 7,
                          child: _buildPreviewWorkspace(),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          flex: 4,
                          child: _buildTimeline(),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  SizedBox(
                    width: 320,
                    child: _buildInspector(),
                  ),
                ],
              ),
            ),
            _buildStatusBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2B2B2B))),
      ),
      child: Row(
        children: [
          const Icon(Icons.movie_creation_outlined, size: 20),
          const SizedBox(width: 10),
          const Text(
            '未命名项目',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 10),
          const Text(
            '1080p · 30fps',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const Spacer(),
          IconButton(
            tooltip: '撤销',
            onPressed: () {},
            icon: const Icon(Icons.undo, size: 19),
          ),
          IconButton(
            tooltip: '重做',
            onPressed: () {},
            icon: const Icon(Icons.redo, size: 19),
          ),
          const VerticalDivider(indent: 11, endIndent: 11),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.file_upload_outlined, size: 18),
            label: const Text('导出'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          const SizedBox(width: 8),
          for (int i = 0; i < _toolIcons.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: IconButton.filledTonal(
                tooltip: switch (i) {
                  0 => '选择',
                  1 => '分割',
                  2 => '裁剪',
                  3 => '音量',
                  _ => '速度',
                },
                isSelected: _selectedTool == i,
                onPressed: () => setState(() => _selectedTool = i),
                icon: Icon(_toolIcons[i], size: 19),
              ),
            ),
          const SizedBox(width: 8),
          const VerticalDivider(indent: 10, endIndent: 10),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.fit_screen_outlined, size: 18),
            label: const Text('适应'),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.grid_view_outlined, size: 18),
            label: const Text('吸附'),
          ),
          const Spacer(),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '16:9', label: Text('16:9')),
              ButtonSegment(value: '9:16', label: Text('9:16')),
              ButtonSegment(value: '1:1', label: Text('1:1')),
            ],
            selected: const {'16:9'},
            onSelectionChanged: (_) {},
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMediaPanel() {
    return Container(
      color: const Color(0xFF161616),
      child: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 2),
              itemBuilder: (context, index) {
                return ChoiceChip(
                  label: Text(_tabs[index]),
                  selected: _selectedTab == index,
                  onSelected: (_) => setState(() => _selectedTab = index),
                  showCheckmark: false,
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: SearchBar(
                    hintText: '搜索素材',
                    leading: const Icon(Icons.search, size: 20),
                    trailing: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.tune, size: 19),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: '导入素材',
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.35,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return _buildMediaCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCard(int index) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {},
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.withValues(alpha: 0.65),
                    Colors.blueGrey.withValues(alpha: 0.35),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  index % 3 == 0
                      ? Icons.videocam_outlined
                      : index % 3 == 1
                          ? Icons.image_outlined
                          : Icons.audiotrack_outlined,
                  size: 32,
                  color: Colors.white70,
                ),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 7,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      index % 3 == 2
                          ? 'music_$index.mp3'
                          : 'clip_$index.mp4',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    index % 3 == 2 ? '02:41' : '00:${12 + index}',
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewWorkspace() {
    return Container(
      color: const Color(0xFF0E0E0E),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  margin: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF333333)),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 28,
                        spreadRadius: 2,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.landscape_outlined,
                          size: 72,
                          color: Colors.white24,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Chip(
                          avatar: const Icon(
                            Icons.circle,
                            size: 10,
                            color: Colors.redAccent,
                          ),
                          label: const Text(
                            '预览',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: IconButton.filledTonal(
                          tooltip: '全屏预览',
                          onPressed: () {},
                          icon: const Icon(Icons.fullscreen, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildPlayerControls(),
        ],
      ),
    );
  }

  Widget _buildPlayerControls() {
    return SizedBox(
      height: 68,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            Slider(
              value: _timelineProgress,
              onChanged: (value) {
                setState(() => _timelineProgress = value);
              },
            ),
            Row(
              children: [
                IconButton(
                  tooltip: '上一帧',
                  onPressed: () {},
                  icon: const Icon(Icons.skip_previous_outlined),
                ),
                IconButton.filled(
                  tooltip: _playing ? '暂停' : '播放',
                  onPressed: () => setState(() => _playing = !_playing),
                  icon: Icon(
                    _playing ? Icons.pause : Icons.play_arrow,
                    size: 20,
                  ),
                ),
                IconButton(
                  tooltip: '下一帧',
                  onPressed: () {},
                  icon: const Icon(Icons.skip_next_outlined),
                ),
                const SizedBox(width: 8),
                const Text(
                  '00:07.82',
                  style: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
                ),
                const Text(' / 00:23.46', style: TextStyle(color: Colors.white54)),
                const Spacer(),
                IconButton(
                  tooltip: '静音',
                  onPressed: () {},
                  icon: const Icon(Icons.volume_up_outlined, size: 19),
                ),
                SizedBox(
                  width: 120,
                  child: Slider(
                    value: 0.76,
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      color: const Color(0xFF151515),
      child: Column(
        children: [
          SizedBox(
            height: 42,
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Text(
                  '时间线',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 14),
                IconButton(
                  tooltip: '放大时间线',
                  onPressed: () {},
                  icon: const Icon(Icons.zoom_in, size: 18),
                ),
                IconButton(
                  tooltip: '缩小时间线',
                  onPressed: () {},
                  icon: const Icon(Icons.zoom_out, size: 18),
                ),
                const Spacer(),
                IconButton(
                  tooltip: '更多',
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildTimelineRuler(),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildTrack(
                            icon: Icons.videocam_outlined,
                            label: '视频 1',
                            clips: const [
                              _ClipData('片段 01', 0.42),
                              _ClipData('片段 02', 0.26),
                              _ClipData('片段 03', 0.34),
                            ],
                          ),
                          _buildTrack(
                            icon: Icons.audiotrack_outlined,
                            label: '音频 1',
                            clips: const [
                              _ClipData('背景音乐', 0.68),
                            ],
                            audio: true,
                          ),
                          _buildTrack(
                            icon: Icons.subtitles_outlined,
                            label: '字幕',
                            clips: const [
                              _ClipData('标题文字', 0.32),
                              _ClipData('字幕', 0.42),
                            ],
                            text: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment(
                    -1 + (_timelineProgress * 1.9),
                    -0.82,
                  ),
                  child: Container(
                    width: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRuler() {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          const SizedBox(width: 82),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    7,
                    (index) => Text(
                      '0${index * 4}:00',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrack({
    required IconData icon,
    required String label,
    required List<_ClipData> clips,
    bool audio = false,
    bool text = false,
  }) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: Colors.white54),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                for (final clip in clips)
                  Expanded(
                    flex: (clip.width * 100).round(),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: _buildClip(
                        clip,
                        audio: audio,
                        text: text,
                      ),
                    ),
                  ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClip(
    _ClipData clip, {
    required bool audio,
    required bool text,
  }) {
    final color = audio
        ? const Color(0xFF496B54)
        : text
            ? const Color(0xFF705A32)
            : const Color(0xFF4D5680);

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(5),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              if (!audio && !text)
                const Icon(
                  Icons.movie_outlined,
                  size: 14,
                  color: Colors.white70,
                ),
              if (audio)
                const Icon(
                  Icons.graphic_eq,
                  size: 14,
                  color: Colors.white70,
                ),
              if (text)
                const Icon(
                  Icons.text_fields,
                  size: 14,
                  color: Colors.white70,
                ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  clip.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInspector() {
    return Container(
      color: const Color(0xFF161616),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 46,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '检查器',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildInspectorSection(
                  title: '变换',
                  children: [
                    _buildDoubleFieldRow('位置 X', '0'),
                    _buildDoubleFieldRow('位置 Y', '0'),
                    _buildDoubleFieldRow('缩放', '100'),
                    _buildDoubleFieldRow('旋转', '0'),
                  ],
                ),
                const SizedBox(height: 10),
                _buildInspectorSection(
                  title: '混合',
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('不透明度'),
                      subtitle: Slider(
                        value: 0.92,
                        onChanged: (_) {},
                      ),
                      trailing: const Text('92%'),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: '正常',
                      decoration: const InputDecoration(
                        labelText: '混合模式',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: '正常',
                          child: Text('正常'),
                        ),
                        DropdownMenuItem(
                          value: '叠加',
                          child: Text('叠加'),
                        ),
                        DropdownMenuItem(
                          value: '滤色',
                          child: Text('滤色'),
                        ),
                      ],
                      onChanged: (_) {},
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildInspectorSection(
                  title: '效果',
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('添加效果'),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.blur_on_outlined),
                      title: const Text('高斯模糊'),
                      subtitle: const Text('强度 12'),
                      trailing: Switch(
                        value: true,
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectorSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDoubleFieldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
          SizedBox(
            width: 110,
            child: TextFormField(
              initialValue: value,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                isDense: true,
                suffixText: ' px',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        border: Border(top: BorderSide(color: Color(0xFF2B2B2B))),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline, size: 14, color: Colors.white54),
          SizedBox(width: 6),
          Text(
            '项目已保存',
            style: TextStyle(fontSize: 11, color: Colors.white54),
          ),
          Spacer(),
          Text(
            '1920 × 1080 · 30 FPS',
            style: TextStyle(fontSize: 11, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _ClipData {
  final String name;
  final double width;

  const _ClipData(this.name, this.width);
}
