import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_samples/models/demo.dart';
import 'package:project_samples/screens/alert_dialog/alert_dialog_example_page.dart';
import 'package:project_samples/screens/animation/animation_example_page.dart';
import 'package:project_samples/screens/annotated_region/annotated_region_sample_page.dart';
import 'package:project_samples/screens/aspect_ratio/aspect_ratio_example_page.dart';
import 'package:project_samples/screens/badge_example_page.dart';
import 'package:project_samples/screens/bottom_app_bar/bottom_app_bar_example_page.dart';
import 'package:project_samples/screens/bottom_sheet/bottom_sheet_example_page.dart';
import 'package:project_samples/screens/box_decoration/box_decoration_example_page.dart';
import 'package:project_samples/screens/button/button_example_page.dart';
import 'package:project_samples/screens/card/card_example_page.dart';
import 'package:project_samples/screens/carousel_view/carousel_view_example_page.dart';
import 'package:project_samples/screens/change_notifier/change_notifier_example_page.dart';
import 'package:project_samples/screens/check_box/check_box_example_page.dart';
import 'package:project_samples/screens/chip/chip_example_page.dart';
import 'package:project_samples/screens/choice_chip/choice_chip_example_page.dart';
import 'package:project_samples/screens/ListView/list_view_example_page.dart';
import 'package:project_samples/screens/Border/border_example_page.dart';
import 'package:project_samples/screens/clipR_rect/clipR_rect_example_page.dart';
import 'package:project_samples/screens/color_scheme/color_scheme_example_page.dart';
import 'package:project_samples/screens/column/column_example_page.dart';
import 'package:project_samples/screens/constrained_box_example_page.dart';
import 'package:project_samples/screens/container/container_example_page.dart';
import 'package:project_samples/screens/date_picker/date_picker_example_page.dart';
import 'package:project_samples/screens/divider_exampler_page.dart';
import 'package:project_samples/screens/drawer/drawer_example_page.dart';
import 'package:project_samples/screens/expanded/expanded_example_page.dart';
import 'package:project_samples/screens/floating_action/floating_action_example_page.dart';
import 'package:project_samples/screens/focus_node/focus_node_example_page.dart';
import 'package:project_samples/screens/form/form_example_page.dart';
import 'package:project_samples/screens/functions/function_example_page.dart';
import 'package:project_samples/screens/future/future_example_page.dart';
import 'package:project_samples/screens/grid_view/grid_view_example_page.dart';
import 'package:project_samples/screens/icon_button/icon_button_example_page.dart';
import 'package:project_samples/screens/ink_well/ink_well_example_page.dart';
import 'package:project_samples/screens/iterable/iterable_example_page.dart';
import 'package:project_samples/screens/limited_box_example_page.dart';
import 'package:project_samples/screens/linear_progress_indicator/linear_progress_indicator_example_page.dart';
import 'package:project_samples/screens/list_tile/list_tile_example_page.dart';
import 'package:project_samples/screens/navigation_bar/navigation_bar_example_page.dart';
import 'package:project_samples/screens/opacity/opacity_example_page.dart';
import 'package:project_samples/screens/page_view/page_view_example_page.dart';
import 'package:project_samples/screens/page_view/page_view_basic_page.dart';
import 'package:project_samples/screens/pass_value/pass_value_example_page.dart';
import 'package:project_samples/screens/popup/popup_example_page.dart';
import 'package:project_samples/screens/progress_indicator_example_page.dart';
import 'package:project_samples/screens/provider/provider_example_page.dart';
import 'package:project_samples/screens/refresh_indicator_example_page.dart';
import 'package:project_samples/screens/scroll/scroll_example_page.dart';
import 'package:project_samples/screens/search_bar/search_bar_example_page.dart';
import 'package:project_samples/screens/segmented_button_example_page.dart';
import 'package:project_samples/screens/silver/silver_example_page.dart';
import 'package:project_samples/screens/snack_bar/snack_bar_example_page.dart';
import 'package:project_samples/screens/stepper/stepper_example_page.dart';
import 'package:project_samples/screens/switch/switch_example_page.dart';
import 'package:project_samples/screens/tab_bar/tab_bar_example_page.dart';
import 'package:project_samples/screens/text_field/text_field_example_page.dart';
import 'package:project_samples/screens/text_form_field/text_form_field_example_page.dart';
import 'package:project_samples/screens/tool_tip/tool_tip_example_page.dart';
import 'package:project_samples/screens/websocket/websocket_example_page.dart';
import 'package:project_samples/utils/color.dart';
import 'package:project_samples/utils/theme_utils.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Examples")),
      body: ListView(
        children: [
          ...basicExamples.map((example) => ExampleTile(example: example)),
        ],
      ),
    );
  }
}

final basicExample = [
  Example(
    name: "Border Example",
    route: BorderExamplePage.routeName,
    builder: (context) => const BorderExamplePage(),
  ),
  Example(
    name: "Limited Box Example",
    route: LimitedBoxExamplePage.routeName,
    builder: (context) => const LimitedBoxExamplePage(),
  ),
  Example(
    name: "Constrained Box Example",
    route: ConstrainedBoxExamplePage.routeName,
    builder: (context) => const ConstrainedBoxExamplePage(),
  ),
  Example(
    name: "Progress Indicator Example",
    route: ProgressIndicatorExamplePage.routeName,
    builder: (context) => const ProgressIndicatorExamplePage(),
  ),
  Example(
    name: "List View Example",
    route: ListViewExamplePage.routeName,
    builder: (context) => const ListViewExamplePage(),
  ),
  Example(
    name: "Choice Chip Example",
    route: ChoiceChipExamplePage.routeName,
    builder: (context) => const ChoiceChipExamplePage(),
  ),
  Example(
    name: "Chip Example",
    route: ChipExamplePage.routeName,
    builder: (context) => const ChipExamplePage(),
  ),
  Example(
    name: "Card Example",
    route: CardExamplePage.routeName,
    builder: (context) => const CardExamplePage(),
  ),
  Example(
    name: "Check Box Example",
    route: CheckBoxExamplePage.routeName,
    builder: (context) => const CheckBoxExamplePage(),
  ),
  Example(
    name: "Segmented Button Example",
    route: SegmentedButtonExamplePage.routeName,
    builder: (context) => const SegmentedButtonExamplePage(),
  ),
  Example(
    name: "Badge Example",
    route: BadgeExamplePage.routeName,
    builder: (context) => const BadgeExamplePage(),
  ),
  Example(
    name: "Date Picker Example",
    route: DatePickerExamplePage.routeName,
    builder: (context) => const DatePickerExamplePage(),
  ),
  Example(
    name: "Button Example",
    route: ButtonExamplePage.routeName,
    builder: (context) => const ButtonExamplePage(),
  ),
  Example(
    name: "List Tile Example",
    route: ListTileExamplePage.routeName,
    builder: (context) => const ListTileExamplePage(),
  ),
  Example(
    name: "Snack Bar Example",
    route: SnackBarExamplePage.routeName,
    builder: (context) => const SnackBarExamplePage(),
  ),
  Example(
    name: "Refresh Indicator Example",
    route: RefreshIndicatorExamplePage.routeName,
    builder: (context) => const RefreshIndicatorExamplePage(),
  ),
  Example(
    name: "Text Field Example",
    route: TextFieldExamplePage.routeName,
    builder: (context) => const TextFieldExamplePage(),
  ),
  Example(
    name: "Grid View Example",
    route: GridViewExamplePage.routeName,
    builder: (context) => const GridViewExamplePage(),
  ),
  Example(
    name: "Divider Example",
    route: DividerExamplePage.routeName,
    builder: (context) => const DividerExamplePage(),
  ),
  Example(
    name: "Alert Dialog Example",
    route: AlertDialogExamplePage.routeName,
    builder: (context) => const AlertDialogExamplePage(),
  ),
  Example(
    name: "Scroll Example",
    route: ScrollExamplePage.routeName,
    builder: (context) => const ScrollExamplePage(),
  ),
  Example(
    name: "Drawer Example",
    route: DrawerExamplePage.routeName,
    builder: (context) => const DrawerExamplePage(),
  ),
  Example(
    name: "Text Form Field Example",
    route: TextFormFieldExamplePage.routeName,
    builder: (context) => const TextFormFieldExamplePage(),
  ),
  Example(
    name: "Page View Example",
    route: PageViewExamplePage.routeName,
    builder: (context) => const PageViewExamplePage(),
  ),
  Example(
    name: "Container Example",
    route: ContainerExamplePage.routeName,
    builder: (context) => const ContainerExamplePage(),
  ),
  Example(
    name: "Expanded Example",
    route: ExpandedExamplePage.routeName,
    builder: (context) => const ExpandedExamplePage(),
  ),
  Example(
    name: "Aspect Ratio Example",
    route: AspectRatioExamplePage.routeName,
    builder: (context) => const AspectRatioExamplePage(),
  ),
  Example(
    name: "Silver Example",
    route: SilverExamplePage.routeName,
    builder: (context) => const SilverExamplePage(),
  ),
  Example(
    name: "TabBar Example",
    route: TabBarExamplePage.routeName,
    builder: (context) => const TabBarExamplePage(),
  ),
  Example(
    name: "Bottom Sheet Example",
    route: BottomSheetExamplePage.routeName,
    builder: (context) => const BottomSheetExamplePage(),
  ),
  Example(
    name: "Floating Action Example",
    route: FloatingActionExamplePage.routeName,
    builder: (context) => const FloatingActionExamplePage(),
  ),
  Example(
    name: "Bottom AppBar Example",
    route: BottomAppBarExamplePage.routeName,
    builder: (context) => const BottomAppBarExamplePage(),
  ),
  Example(
    name: "NavigationBar Example",
    route: NavigationBarExamplePage.routeName,
    builder: (context) => const NavigationBarExamplePage(),
  ),
  Example(
    name: "Form Example",
    route: FormExamplePage.routeName,
    builder: (context) => const FormExamplePage(),
  ),
  Example(
    name: "Icon Button Example",
    route: IconButtonExamplePage.routeName,
    builder: (context) => const IconButtonExamplePage(),
  ),
  Example(
    name: "Carousel View Example",
    route: CarouselViewExamplePage.routeName,
    builder: (context) => const CarouselViewExamplePage(),
  ),
  Example(
    name: "Iterable Example",
    route: IterableExamplePage.routeName,
    builder: (context) => const IterableExamplePage(),
  ),
  Example(
    name: "Focus Node Example",
    route: FocusNodeExamplePage.routeName,
    builder: (context) => const FocusNodeExamplePage(),
  ),
  Example(
    name: "Linear Progress Indicator Example",
    route: LinearProgressIndicatorExamplePage.routeName,
    builder: (context) => const LinearProgressIndicatorExamplePage(),
  ),
  Example(
    name: "Animation Example",
    route: AnimationExamplePage.routeName,
    builder: (context) => const AnimationExamplePage(),
  ),
  Example(
    name: "Search Bar Example",
    route: SearchBarExamplePage.routeName,
    builder: (context) => const SearchBarExamplePage(),
  ),
  Example(
    name: "Tooltip Example",
    route: ToolTipExamplePage.routeName,
    builder: (context) => const ToolTipExamplePage(),
  ),
  Example(
    name: "Future Example",
    route: FutureExamplePage.routeName,
    builder: (context) => const FutureExamplePage(),
  ),
  Example(
    name: "Color Scheme Example",
    route: ColorSchemeExamplePage.routeName,
    builder: (context) => const ColorSchemeExamplePage(),
  ),
  Example(
    name: "Websocket Example",
    route: WebsocketExamplePage.routeName,
    builder: (context) => WebsocketExamplePage(channel: WebSocketChannel.connect(Uri.parse('ws://echo.websocket.org'))),
  ),
  Example(
    name: "ClipRRect Example",
    route: CliprRectExamplePage.routeName,
    builder: (context) => const CliprRectExamplePage(),
  ),
  Example(
    name: "AnnotatedRegion Example",
    route: AnnotatedRegionSamplePage.routeName,
    builder: (context) => const AnnotatedRegionSamplePage(),
  ),
  Example(
    name: "Stepper Example",
    route: StepperExamplePage.routeName,
    builder: (context) => const StepperExamplePage(),
  ),
  Example(
    name: "Opacity Example",
    route: OpacityExamplePage.routeName,
    builder: (context) => const OpacityExamplePage(),
  ),
  Example(
    name: "InkWell Example",
    route: InkWellExamplePage.routeName,
    builder: (context) => const InkWellExamplePage(),
  ),
  Example(
    name: "Pass Value Example",
    route: PassValueExamplePage.routeName,
    builder: (context) => const PassValueExamplePage(),
  ),
  Example(
    name: "Function Example",
    route: FunctionExamplePage.routeName,
    builder: (context) => const FunctionExamplePage(),
  ),
  Example(
    name: "Popup Example",
    route: PopupExamplePage.routeName,
    builder: (context) => const PopupExamplePage(),
  ),
  Example(
    name: "Change Notifier Example",
    route: ChangeNotifierExamplePage.routeName,
    builder: (context) => const ChangeNotifierExamplePage(),
  ),
  Example(
    name: "Provider Example",
    route: ProviderExamplePage.routeName,
    builder: (context) => const ProviderExamplePage(),
  ),
  Example(
    name: "Column Example",
    route: ColumnExamplePage.routeName,
    builder: (context) => const ColumnExamplePage(),
  ),
  Example(
    name: "Switch Example",
    route: SwitchExamplePage.routeName,
    builder: (context) => const SwitchExamplePage(),
  ),
  Example(
    name: "BoxDecoration Example",
    route: BoxDecorationExamplePage.routeName,
    builder: (context) => const BoxDecorationExamplePage(),
  ),
];

final basicExamples = [...basicExample]
  ..sort((a, b) => a.name.compareTo(b.name));

class ExampleTile extends StatelessWidget {
  final Example example;

  const ExampleTile({super.key, required this.example});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        example.name,
        style: TextStyle(
          color: context.isDark ? AppColor.darkText : AppColor.text,
        ),
      ),
      onTap: () {
        context.go('/${example.route}');
      },
    );
  }
}
