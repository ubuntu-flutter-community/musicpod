import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../settings_model.dart';

/// 自定义主题配置对话框
class CustomThemeDialog extends StatefulWidget {
  const CustomThemeDialog({super.key});

  @override
  State<CustomThemeDialog> createState() => _CustomThemeDialogState();
}

class _CustomThemeDialogState extends State<CustomThemeDialog> {
  late List<Color> selectedColors;
  late bool useGradient;
  final maxColors = 5; // 最多支持5个颜色

  @override
  void initState() {
    super.initState();
    final model = di<SettingsModel>();
    selectedColors = List.from(model.customThemeColors);
    useGradient = model.useGradientTheme;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('自定义主题'),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            _buildColorList(),
            const SizedBox(height: kLargestSpace),
            _buildActionButtons(),
            const SizedBox(height: kLargestSpace),
            _buildGradientSwitch(),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('取消'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('保存'),
          onPressed: _saveTheme,
        ),
      ],
    );
  }

  Widget _buildColorList() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '选择颜色${useGradient ? " (渐变)" : ""}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedColors.length + (selectedColors.length < maxColors ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < selectedColors.length) {
                  // 已有颜色项
                  return _buildColorItem(index);
                } else {
                  // 添加按钮
                  return _buildAddColorButton();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorItem(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: GestureDetector(
          onTap: () => _pickColor(index),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selectedColors[index],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
        ),
        title: Text('颜色 ${index + 1}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: selectedColors.length > 1 ? () => _removeColor(index) : null,
        ),
      ),
    );
  }

  Widget _buildAddColorButton() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: const Text('添加颜色'),
        leading: const Icon(Icons.add_circle_outline),
        onTap: _addNewColor,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.color_lens),
          label: const Text('预设颜色'),
          onPressed: _showPresetColors,
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('重置'),
          onPressed: _resetToDefault,
        ),
      ],
    );
  }

  Widget _buildGradientSwitch() {
    return SwitchListTile(
      title: const Text('使用渐变效果'),
      subtitle: const Text('使用多个颜色创建渐变效果'),
      value: useGradient,
      onChanged: (value) {
        setState(() {
          useGradient = value;
        });
      },
    );
  }

  // 显示颜色选择器
  void _pickColor(int index) {
    showDialog(
      context: context,
      builder: (context) {
        Color pickerColor = selectedColors[index];
        return AlertDialog(
          title: const Text('选择颜色'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedColors[index] = pickerColor;
                });
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 移除颜色
  void _removeColor(int index) {
    setState(() {
      selectedColors.removeAt(index);
    });
  }

  // 添加新颜色
  void _addNewColor() {
    if (selectedColors.length < maxColors) {
      setState(() {
        // 添加一个与最后一个颜色相似但稍微不同的颜色
        final lastColor = selectedColors.last;
        final newColor = Color.fromARGB(
          lastColor.alpha,
          (lastColor.red + 25) % 256,
          (lastColor.green + 25) % 256,
          (lastColor.blue + 25) % 256,
        );
        selectedColors.add(newColor);
      });
    }
  }

  // 显示预设颜色方案
  void _showPresetColors() {
    final presets = [
      [Colors.blue.shade500],
      [Colors.red.shade500],
      [Colors.green.shade500],
      [Colors.purple.shade500],
      [Colors.orange.shade500],
      [Colors.blue.shade300, Colors.purple.shade300],
      [Colors.pink.shade300, Colors.purple.shade500],
      [Colors.blue.shade300, Colors.green.shade500],
      [Colors.orange.shade300, Colors.red.shade500],
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择预设颜色'),
          content: SizedBox(
            width: 400,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: presets.map((colorSet) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedColors = List.from(colorSet);
                      useGradient = colorSet.length > 1;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                      gradient: colorSet.length > 1
                          ? LinearGradient(
                              colors: colorSet,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: colorSet.length == 1 ? colorSet[0] : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  // 重置为默认颜色
  void _resetToDefault() {
    setState(() {
      selectedColors = [Colors.blue.shade500];
      useGradient = false;
    });
  }

  // 保存主题设置
  void _saveTheme() {
    final model = di<SettingsModel>();
    
    // 如果启用渐变但只有一个颜色，自动添加第二个颜色
    if (useGradient && selectedColors.length < 2) {
      // 添加一个派生的第二个颜色
      final color = selectedColors.first;
      final secondColor = Color.fromARGB(
        color.alpha,
        (color.red + 40) % 256,
        (color.green + 40) % 256,
        (color.blue + 40) % 256,
      );
      selectedColors.add(secondColor);
    }
    
    model.setCustomThemeColors(selectedColors);
    model.setUseGradientTheme(useGradient);
    
    Navigator.of(context).pop();
  }
} 