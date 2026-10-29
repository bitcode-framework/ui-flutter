// Media demo - BcViewerVideo, BcViewerAudio, BcViewerImage, BcViewerPdf,
// BcViewerDocument, BcViewerYoutube, BcViewerInstagram, BcViewerTiktok,
// BcGalleria, BcImage, BcWebcam.
library media_section;

import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import '../demo_widgets.dart';

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
            src: '',
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
          description: 'Image viewer with zoom, pan, and fullscreen. Empty src shows failed state.',
          child: SizedBox(
            height: 200,
            child: BcViewerImage(
              src: '',
              fit: BcViewerImageFit.cover,
            ),
          ),
        ),

        // -- BcViewerVideo --
        DemoCard(
          title: 'BcViewerVideo',
          description: 'Video player with play/pause, volume, and fullscreen. Empty src shows failed state.',
          child: SizedBox(
            height: 200,
            child: BcViewerVideo(
              src: '',
            ),
          ),
        ),

        // -- BcViewerAudio --
        DemoCard(
          title: 'BcViewerAudio',
          description: 'Audio player with play/pause and scrubber. Empty src shows failed state.',
          child: SizedBox(
            height: 120,
            child: BcViewerAudio(
              src: '',
            ),
          ),
        ),

        // -- BcViewerPdf --
        DemoCard(
          title: 'BcViewerPdf',
          description: 'PDF viewer with page navigation and zoom controls.',
          child: SizedBox(
            height: 200,
            child: BcViewerPdf(
              src: '',
              pageCount: 10,
            ),
          ),
        ),

        // -- BcViewerYoutube --
        DemoCard(
          title: 'BcViewerYoutube',
          description: 'YouTube embed. Invalid/empty video ID shows a placeholder.',
          child: SizedBox(
            height: 200,
            child: BcViewerYoutube(
              videoId: '',
            ),
          ),
        ),

        // -- BcGalleria --
        DemoCard(
          title: 'BcGalleria',
          description: 'Image gallery with thumbnails and optional lightbox. Empty list shows placeholder.',
          child: SizedBox(
            height: 200,
            child: BcGalleria(
              images: const [],
              emptyText: 'No images in gallery',
            ),
          ),
        ),

        // -- BcLightbox --
        DemoCard(
          title: 'BcLightbox',
          description: 'Full-screen image gallery with swipe navigation (default-open for demo).',
          child: BcLightbox(
            defaultOpen: true,
            items: const [
              BcLightboxItem.image('https://picsum.photos/seed/bc1/800/600', alt: 'Sample 1'),
              BcLightboxItem.image('https://picsum.photos/seed/bc2/800/600', alt: 'Sample 2'),
              BcLightboxItem.image('https://picsum.photos/seed/bc3/800/600', alt: 'Sample 3'),
            ],
          ),
        ),

        // -- BcMap --
        DemoCard(
          title: 'BcMap',
          description: 'Interactive map (dependency-free, caller wires the map plugin).',
          child: BcMap(
            height: 200,
            center: const BcMapLatLng(lat: -6.2088, lng: 106.8456),
            zoom: 12,
            markers: const [
              BcMapMarker(id: 'hq', lat: -6.2088, lng: 106.8456, label: 'HQ'),
              BcMapMarker(id: 'branch', lat: -6.2200, lng: 106.8600, label: 'Branch'),
            ],
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
            src: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
            title: 'Dummy.pdf',
            pageCount: 2,
          ),
        ),

        // -- BcViewerInstagram --
        DemoCard(
          title: 'BcViewerInstagram',
          description: 'Instagram post embed (renders an iframe on web; shows fallback on native).',
          child: const BcViewerInstagram(
            url: 'https://www.instagram.com/p/CpABC123xyz/',
            title: 'Instagram Post',
            captioned: true,
          ),
        ),

        // -- BcViewerTiktok --
        DemoCard(
          title: 'BcViewerTiktok',
          description: 'TikTok video embed (renders an iframe on web; shows fallback on native).',
          child: const BcViewerTiktok(
            videoId: '7106594319322901509',
            title: 'TikTok Video',
          ),
        ),
      ],
    );
  }
}