const std = @import("std");
const c = @cImport({
    @cInclude("thorvg_capi.h");
    @cInclude("SDL2/SDL.h");
});

fn draw(allocator: std.mem.Allocator, canvas: *c.Tvg_Canvas) !*c.Tvg_Animation {
    // 1. Linear gradient shape with a linear gradient stroke
    // Set a shape
    const shape1 = c.tvg_shape_new().?;
    _ = c.tvg_shape_move_to(shape1, 25.0, 25.0);
    _ = c.tvg_shape_line_to(shape1, 375.0, 25.0);
    _ = c.tvg_shape_cubic_to(shape1, 500.0, 100.0, -500.0, 200.0, 375.0, 375.0);
    _ = c.tvg_shape_close(shape1);

    // Prepare a gradient for the fill
    const grad1 = c.tvg_linear_gradient_new().?;
    _ = c.tvg_linear_gradient_set(grad1, 25.0, 25.0, 200.0, 200.0);
    const color_stops1 = [_]c.Tvg_Color_Stop{
        .{
            .offset = 0.00,
            .r = 255,
            .g = 0,
            .b = 0,
            .a = 155,
        },
        .{
            .offset = 0.33,
            .r = 0,
            .g = 255,
            .b = 0,
            .a = 100,
        },
        .{
            .offset = 0.66,
            .r = 255,
            .g = 0,
            .b = 255,
            .a = 100,
        },
        .{
            .offset = 1.00,
            .r = 0,
            .g = 0,
            .b = 255,
            .a = 155,
        },
    };
    _ = c.tvg_gradient_set_color_stops(grad1, &color_stops1, 4);
    _ = c.tvg_gradient_set_spread(grad1, c.TVG_STROKE_FILL_REFLECT);

    // Prepare a gradient for the stroke
    const grad1_stroke = c.tvg_gradient_duplicate(grad1).?;

    // Set a gradient fill
    _ = c.tvg_shape_set_linear_gradient(shape1, grad1);

    // Set a gradient stroke
    _ = c.tvg_shape_set_stroke_width(shape1, 20.0);
    _ = c.tvg_shape_set_stroke_linear_gradient(shape1, grad1_stroke);
    _ = c.tvg_shape_set_stroke_join(shape1, c.TVG_STROKE_JOIN_ROUND);

    // 2. Solid transformed shape
    // Set a shape
    var cmds: [*c]c.Tvg_Path_Command = null;
    var cmdCnt: u32 = 0;
    var pts: [*c]c.Tvg_Point = null;
    var ptsCnt: u32 = 0;

    const shape2 = c.tvg_shape_new().?;
    _ = c.tvg_shape_get_path_commands(shape1, &cmds, &cmdCnt);
    _ = c.tvg_shape_get_path_coords(shape1, &pts, &ptsCnt);

    _ = c.tvg_shape_append_path(shape2, cmds, cmdCnt, pts, ptsCnt);
    _ = c.tvg_shape_set_fill_color(shape2, 255, 255, 255, 128);

    // Transform a shape
    _ = c.tvg_paint_scale(shape2, 0.3);
    _ = c.tvg_paint_translate(shape2, 100.0, 100.0);

    // Push shapes 1 and 2 into the canvas
    _ = c.tvg_canvas_push(canvas, shape1);
    _ = c.tvg_canvas_push(canvas, shape2);

    // 3. Radial gradient shape with a radial dashed stroke
    // Set a shape
    const shape3 = c.tvg_shape_new().?;
    _ = c.tvg_shape_append_rect(shape3, 550.0, 20.0, 100.0, 50.0, 0.0, 0.0);
    _ = c.tvg_shape_append_circle(shape3, 600.0, 150.0, 100.0, 50.0);
    _ = c.tvg_shape_append_rect(shape3, 550.0, 230.0, 100.0, 100.0, 20.0, 40.0);

    // Prepare a radial gradient for the fill
    const grad2 = c.tvg_radial_gradient_new().?;
    _ = c.tvg_radial_gradient_set(grad2, 600.0, 180.0, 50.0);
    const color_stops2 =
        [_]c.Tvg_Color_Stop{
        .{ .offset = 0.0, .r = 255, .g = 0, .b = 255, .a = 255 },
        .{ .offset = 0.5, .r = 0, .g = 0, .b = 255, .a = 255 },
        .{ .offset = 1.0, .r = 50, .g = 55, .b = 155, .a = 255 },
    };
    _ = c.tvg_gradient_set_color_stops(grad2, &color_stops2, 3);
    _ = c.tvg_gradient_set_spread(grad2, c.TVG_STROKE_FILL_PAD);

    // Set a gradient fill
    _ = c.tvg_shape_set_radial_gradient(shape3, grad2);

    // Prepare a radial gradient for the stroke
    var cnt: u32 = 0;
    var color_stops2_get: [*c]c.Tvg_Color_Stop = null;
    _ = c.tvg_gradient_get_color_stops(grad2, &color_stops2_get, &cnt);

    var cx: f32 = 0;
    var cy: f32 = 0;
    var radius: f32 = 0;
    _ = c.tvg_radial_gradient_get(grad2, &cx, &cy, &radius);

    const grad2_stroke = c.tvg_radial_gradient_new().?;
    _ = c.tvg_radial_gradient_set(grad2_stroke, cx, cy, radius);
    _ = c.tvg_gradient_set_color_stops(grad2_stroke, color_stops2_get, cnt);
    _ = c.tvg_gradient_set_spread(grad2_stroke, c.TVG_STROKE_FILL_REPEAT);

    // Set a gradient stroke
    _ = c.tvg_shape_set_stroke_width(shape3, 30.0);
    _ = c.tvg_shape_set_stroke_radial_gradient(shape3, grad2_stroke);

    _ = c.tvg_paint_set_opacity(shape3, 200);

    // Push the shape into the canvas
    _ = c.tvg_canvas_push(canvas, shape3);

    // 4. Scene
    // Set a scene
    const scene = c.tvg_scene_new().?;

    // Set circles
    const scene_shape1 = c.tvg_shape_new().?;
    _ = c.tvg_shape_append_circle(scene_shape1, 80.0, 650, 40.0, 140.0);
    _ = c.tvg_shape_append_circle(scene_shape1, 180.0, 600, 40.0, 60.0);
    _ = c.tvg_shape_set_fill_color(scene_shape1, 0, 0, 255, 150);
    _ = c.tvg_shape_set_stroke_color(scene_shape1, 75, 25, 155, 255);
    _ = c.tvg_shape_set_stroke_width(scene_shape1, 10.0);
    _ = c.tvg_shape_set_stroke_cap(scene_shape1, c.TVG_STROKE_CAP_ROUND);
    _ = c.tvg_shape_set_stroke_join(scene_shape1, c.TVG_STROKE_JOIN_ROUND);
    _ = c.tvg_shape_set_stroke_trim(scene_shape1, 0.25, 0.75, true);

    // Set circles with a dashed stroke
    const scene_shape2 = c.tvg_paint_duplicate(scene_shape1).?;
    _ = c.tvg_shape_set_fill_color(scene_shape2, 75, 25, 155, 200);

    // Prapare a dash for the stroke
    const dashPattern = [4]f32{ 15.0, 30.0, 2.0, 30.0 };
    _ = c.tvg_shape_set_stroke_dash(scene_shape2, &dashPattern, 4, 0.0);
    _ = c.tvg_shape_set_stroke_cap(scene_shape2, c.TVG_STROKE_CAP_ROUND);
    _ = c.tvg_shape_set_stroke_color(scene_shape2, 0, 0, 255, 255);
    _ = c.tvg_shape_set_stroke_width(scene_shape2, 15.0);

    // Transform a shape
    _ = c.tvg_paint_scale(scene_shape2, 0.8);
    _ = c.tvg_paint_rotate(scene_shape2, -90.0);
    _ = c.tvg_paint_translate(scene_shape2, -200.0, 800.0);

    // Push the shapes into the scene
    _ = c.tvg_scene_push(scene, scene_shape1);
    _ = c.tvg_scene_push(scene, scene_shape2);

    // Push the scene into the canvas
    _ = c.tvg_canvas_push(canvas, scene);

    // 5. Masked picture
    // Set a scene
    const pict = c.tvg_picture_new().?;

    if (c.tvg_picture_load(pict, "zig-out/tiger.svg") != c.TVG_RESULT_SUCCESS) {
        std.log.err("Problem with loading tiger SVG file", .{});
        _ = c.tvg_paint_del(pict);
    } else {
        var w: f32 = 0;
        var h: f32 = 0;
        _ = c.tvg_picture_get_size(pict, &w, &h);
        _ = c.tvg_picture_set_size(pict, w / 2, h / 2);
        const m = c.Tvg_Matrix{
            .e11 = 0.8,
            .e12 = 0.0,
            .e13 = 400.0,
            .e21 = 0.0,
            .e22 = 0.8,
            .e23 = 400.0,
            .e31 = 0.0,
            .e32 = 0.0,
            .e33 = 1.0,
        };
        _ = c.tvg_paint_set_transform(pict, &m);

        // Set a composite shape
        const comp = c.tvg_shape_new().?;
        _ = c.tvg_shape_append_circle(comp, 600.0, 600.0, 100.0, 100.0);
        _ = c.tvg_shape_set_fill_color(comp, 0, 0, 0, 200);
        _ = c.tvg_paint_set_mask_method(pict, comp, c.TVG_MASK_METHOD_INVERSE_ALPHA);

        //Push the scene into the canvas
        _ = c.tvg_canvas_push(canvas, pict);
    }

    // 6. Animation with a picture
    // Instead loading from memory, an animation can be loaded directly from a file using:
    // `c.tvg_picture_load(pict_lottie, "zig-out/sample.json")`
    const animation_data = try std.fs.cwd().readFileAllocOptions(
        allocator,
        "zig-out/sample.json",
        std.math.maxInt(usize),
        null,
        @alignOf(u8),
        0,
    );
    defer allocator.free(animation_data);

    const animation = c.tvg_animation_new().?;
    const pict_lottie = c.tvg_animation_get_picture(animation).?;
    if (c.tvg_picture_load_data(
        pict_lottie,
        animation_data,
        @intCast(animation_data.len),
        null,
        null,
        false,
    ) != c.TVG_RESULT_SUCCESS) {
        std.log.err("Problem with loading a lottie file", .{});
        _ = c.tvg_animation_del(animation);
    } else {
        _ = c.tvg_paint_scale(pict_lottie, 3.0);
        _ = c.tvg_canvas_push(canvas, pict_lottie);
    }

    // 7. Text
    // Load from a file
    if (c.tvg_font_load("zig-out/SentyCloud.ttf") != c.TVG_RESULT_SUCCESS) {
        std.log.err("Problem with loading the font from the file. Did you enable TTF Loader?", .{});
    } else {
        const text = c.tvg_text_new().?;
        _ = c.tvg_text_set_font(text, "SentyCloud", 25.0, "");
        _ = c.tvg_text_set_fill_color(text, 0, 0, 255);
        _ = c.tvg_text_set_text(
            text,
            "\xE7\xB4\xA2\xE5\xB0\x94\x56\x47\x20\xE6\x98\xAF\xE6\x9C\x80\xE5\xA5\xBD\xE7\x9A\x84",
        );
        _ = c.tvg_paint_translate(text, 50.0, 380.0);
        _ = c.tvg_canvas_push(canvas, text);
    }

    // Load from memory

    const font_data = try std.fs.cwd().readFileAlloc(
        allocator,
        "zig-out/SentyCloud.ttf",
        std.math.maxInt(usize),
    );
    defer allocator.free(font_data);

    if (c.tvg_font_load_data(
        "Arial",
        font_data.ptr,
        @intCast(font_data.len),
        "ttf",
        true,
    ) != c.TVG_RESULT_SUCCESS) {
        std.log.err("Problem with loading the font file from memory.", .{});
    } else {
        // Radial gradient
        const grad = c.tvg_radial_gradient_new().?;
        _ = c.tvg_radial_gradient_set(grad, 200.0, 200.0, 20.0);
        const color_stops = [_]c.Tvg_Color_Stop{
            .{
                .offset = 0.0,
                .r = 255,
                .g = 0,
                .b = 255,
                .a = 255,
            },
            .{
                .offset = 1.0,
                .r = 0,
                .g = 0,
                .b = 255,
                .a = 255,
            },
        };
        _ = c.tvg_gradient_set_color_stops(grad, &color_stops, 2);
        _ = c.tvg_gradient_set_spread(grad, c.TVG_STROKE_FILL_REFLECT);

        const text = c.tvg_text_new().?;
        _ = c.tvg_text_set_font(text, "Arial", 20.0, "italic");
        _ = c.tvg_text_set_gradient(text, grad);
        _ = c.tvg_text_set_text(text, "ThorVG is the best");
        _ = c.tvg_paint_translate(text, 70.0, 420.0);
        _ = c.tvg_canvas_push(canvas, text);
    }

    return animation;
}

fn progress(elapsed: u32, durationInSec: f32) f32 {
    const duration: u32 = @intFromFloat(durationInSec * 1000.0); // sec -> millisec.
    const clamped = elapsed % duration;
    return @as(f32, @floatFromInt(clamped)) / @as(f32, @floatFromInt(duration));
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    _ = c.tvg_engine_init(c.TVG_ENGINE_SW, 0);

    _ = c.SDL_Init(c.SDL_INIT_VIDEO);

    const window = c.SDL_CreateWindow(
        "ThorVG Example (Software Renderer, Zig)",
        c.SDL_WINDOWPOS_UNDEFINED,
        c.SDL_WINDOWPOS_UNDEFINED,
        800,
        800,
        c.SDL_WINDOW_SHOWN,
    ).?;
    const surface = c.SDL_GetWindowSurface(window);

    // create the canvas
    const canvas = c.tvg_swcanvas_create().?;
    _ = c.tvg_swcanvas_set_target(
        canvas,
        @as([*]u32, @alignCast(@ptrCast(surface.*.pixels))),
        @intCast(surface.*.w),
        @intCast(@divTrunc(surface.*.pitch, 4)),
        @intCast(surface.*.h),
        c.TVG_COLORSPACE_ARGB8888,
    );
    _ = c.tvg_swcanvas_set_mempool(canvas, c.TVG_MEMPOOL_POLICY_DEFAULT);

    const animation = try draw(allocator, canvas);

    var event: c.SDL_Event = undefined;
    var running = true;
    var ptime = c.SDL_GetTicks();
    var elapsed: u32 = 0;

    while (running) {
        //SDL Event handling
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    running = false;
                },
                c.SDL_KEYUP => {
                    if (event.key.keysym.sym == c.SDLK_ESCAPE) {
                        running = false;
                    }
                },
                else => {},
            }
        }

        //Clear the canvas
        _ = c.tvg_canvas_clear(canvas, false, true);

        //Update the animation
        var duration: f32 = 0;
        var totalFrame: f32 = 0;
        _ = c.tvg_animation_get_duration(animation, &duration);
        _ = c.tvg_animation_get_total_frame(animation, &totalFrame);
        _ = c.tvg_animation_set_frame(animation, totalFrame * progress(elapsed, duration));

        //Draw the canvas
        _ = c.tvg_canvas_update(canvas);
        _ = c.tvg_canvas_draw(canvas);
        _ = c.tvg_canvas_sync(canvas);

        _ = c.SDL_UpdateWindowSurface(window);

        const ctime = c.SDL_GetTicks();
        elapsed += (ctime - ptime);
        ptime = ctime;
    }

    c.SDL_DestroyWindow(window);

    c.SDL_Quit();

    _ = c.tvg_engine_term(c.TVG_ENGINE_SW);
}
