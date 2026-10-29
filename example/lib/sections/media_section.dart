// Media demo - BcViewerVideo, BcViewerAudio, BcViewerImage, BcViewerPdf,
// BcViewerDocument, BcViewerYoutube, BcViewerInstagram, BcViewerTiktok,
// BcGalleria, BcImage, BcWebcam.
library media_section;

import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import '../demo_widgets.dart';

/// Opens a [BcLightbox] on demand.
///
/// `BcLightbox` renders a full-screen overlay while open, so leaving it
/// permanently open (the previous demo behaviour) covered every section below
/// it and made the rest of the page unreachable.
class _LightboxDemo extends StatefulWidget {
  const _LightboxDemo();

  @override
  State<_LightboxDemo> createState() => _LightboxDemoState();
}

class _LightboxDemoState extends State<_LightboxDemo> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return BcYStack(
      gap: 12,
      children: [
        ElevatedButton(
          onPressed: () => setState(() => _open = true),
          child: const Text('Open lightbox'),
        ),
        if (_open)
          BcLightbox(
            defaultOpen: true,
            onOpenChange: (isOpen, _) {
              if (!isOpen) setState(() => _open = false);
            },
            items: const [
              BcLightboxItem.image('https://picsum.photos/seed/bc1/800/600',
                  alt: 'Sample 1'),
              BcLightboxItem.image('https://picsum.photos/seed/bc2/800/600',
                  alt: 'Sample 2'),
              BcLightboxItem.image('https://picsum.photos/seed/bc3/800/600',
                  alt: 'Sample 3'),
            ],
          ),
      ],
    );
  }
}

class MediaSection extends StatelessWidget {
  const MediaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BcYStack(
      gap: 24,
      children: [
        const SectionHeader(
          title: 'Media',
          subtitle: 'Image, video, audio, PDF viewers, YouTube embeds, and galleries.',
        ),

        // -- BcImage --
        DemoCard(
          title: 'BcImage',
          description: 'Image with placeholder, error fallback, and tap interaction.',
          child: BcImage(
            src: 'https://picsum.photos/seed/bc-image/400/240',
            alt: 'Sample image',
            width: 320,
            height: 180,
            fit: BcImageFit.cover,
            rounded: true,
            errorFallback: Container(
              width: 320,
              height: 180,
              color: BcTheme.muted,
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image_outlined, size: 40),
                  SizedBox(height: 8),
                  Text('Image placeholder'),
                ],
              ),
            ),
          ),
        ),

        // -- BcViewerImage --
        DemoCard(
          title: 'BcViewerImage',
          description: 'Image viewer with zoom, pan, and fullscreen.',
          child: SizedBox(
            height: 200,
            child: BcViewerImage(
              src: 'https://picsum.photos/seed/bc-viewer-image/800/500',
              fit: BcViewerImageFit.cover,
            ),
          ),
        ),

        // -- BcViewerVideo --
        DemoCard(
          title: 'BcViewerVideo',
          description: 'Video player. Renders a native <video> element on web.',
          child: SizedBox(
            height: 240,
            child: BcViewerVideo(
              src: 'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',
              type: 'video/mp4',
              poster: 'https://picsum.photos/seed/bc-video-poster/800/450',
              duration: const Duration(seconds: 4),
            ),
          ),
        ),

        // -- BcViewerAudio --
        DemoCard(
          title: 'BcViewerAudio',
          description: 'Audio player. Renders a native <audio> element on web.',
          child: BcViewerAudio(
            src: 'https://interactive-examples.mdn.mozilla.net/media/cc0-audio/t-rex-roar.mp3',
            type: 'audio/mpeg',
            title: 'T-Rex roar',
            duration: const Duration(seconds: 4),
          ),
        ),

        // -- BcViewerPdf --
        DemoCard(
          title: 'BcViewerPdf',
          description: 'PDF viewer. Renders a real iframe embed on web.',
          child: SizedBox(
            height: 320,
            child: BcViewerPdf(
              src: 'https://pdfobject.com/pdf/sample.pdf',
              pageCount: 1,
            ),
          ),
        ),

        // -- BcViewerYoutube --
        DemoCard(
          title: 'BcViewerYoutube',
          description: 'YouTube embed. Renders a real iframe on web.',
          child: const BcViewerYoutube(
            videoId: 'dQw4w9WgXcQ',
            title: 'YouTube video',
          ),
        ),

        // -- BcGalleria --
        DemoCard(
          title: 'BcGalleria',
          description: 'Image gallery with thumbnails and optional lightbox.',
          child: BcGalleria(
            images: const [
                BcGalleriaItem(
                  id: 'g1',
                  src: 'https://picsum.photos/seed/bcg1/400/300',
                  alt: 'Sample 1',
                ),
                BcGalleriaItem(
                  id: 'g2',
                  src: 'https://picsum.photos/seed/bcg2/400/300',
                  alt: 'Sample 2',
                ),
                BcGalleriaItem(
                  id: 'g3',
                  src: 'https://picsum.photos/seed/bcg3/400/300',
                  alt: 'Sample 3',
                ),
                BcGalleriaItem(
                  id: 'g4',
                  src: 'https://picsum.photos/seed/bcg4/400/300',
                  alt: 'Sample 4',
                ),
              ],
              emptyText: 'No images in gallery',
          ),
        ),

        // -- BcLightbox --
        // Closed by default: when open it renders a full-screen overlay that
        // covers the whole demo page and hides every section below it.
        DemoCard(
          title: 'BcLightbox',
          description: 'Full-screen image gallery with swipe navigation. Tap the button to open.',
          child: _LightboxDemo(),
        ),

        // -- BcMap --
        DemoCard(
          title: 'BcMap',
          description: 'Interactive map (dependency-free, caller wires the map plugin).',
          child: BcMap(
            height: 260,
            center: const BcMapLatLng(lat: -6.2088, lng: 106.8456),
            zoom: 12,
          ),
        ),

        // -- BcWebcam --
        DemoCard(
          title: 'BcWebcam',
          description: 'Camera capture (dependency-free, caller wires the camera plugin).',
          child: BcWebcam(
            captureLabel: 'Take Photo',
          ),
        ),

        // -- BcViewerDocument --
        DemoCard(
          title: 'BcViewerDocument',
          description: 'Office/PDF document viewer with page navigation (renders an iframe embed on web).',
          child: const BcViewerDocument(
            src: 'https://pdfobject.com/pdf/sample.pdf',
            title: 'sample.pdf',
            pageCount: 1,
            engine: BcViewerDocumentEngine.native,
          ),
        ),

        // -- BcViewerInstagram --
        // Instagram only renders an embed for a logged-in session, so this
        // shows Instagram's own login prompt inside the iframe. The widget is
        // correct; the platform gates the content.
        DemoCard(
          title: 'BcViewerInstagram',
          description: 'Instagram post embed (real iframe on web). Instagram requires a logged-in session, so it shows its own prompt.',
          child: const BcViewerInstagram(
            url: 'https://www.instagram.com/p/C2XqYQ8J8Zz/',
            title: 'Instagram Post',
            captioned: true,
          ),
        ),

        // -- BcViewerTiktok --
        // A real TikTok video id. TikTok may rate-limit anonymous embeds from
        // datacenter IPs ("overload_protect triggered" inside the iframe); the
        // widget still mounts the correct iframe.
        DemoCard(
          title: 'BcViewerTiktok',
          description: 'TikTok video embed (real iframe on web).',
          child: const BcViewerTiktok(
            videoId: '6718335390845095173',
            title: 'TikTok Video',
          ),
        ),
      ],
    );
  }
}