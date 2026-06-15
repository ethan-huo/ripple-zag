import * as imageCropper from '@zag-js/image-cropper';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';

export function ImageCropper() @{
	let service = useMachine(imageCropper.machine, {
		id: 'image-cropper',
		initialCrop: { x: 140, y: 170, width: 200, height: 150 },
	});
	let api = track(() => imageCropper.connect(service, normalizeProps));

	let previewUrl = track('');

    async function updatePreview() {
        // const dataUrl = await api.value.getCroppedImage({
        //     output: "dataUrl",
        //     type: "image/png",
        // });

        // if (dataUrl) {
        //     previewUrl.value = dataUrl;
        // }

    }

    function resetCrop() {
        previewUrl.value = '';
    }

    <>
    @if (!previewUrl.value) {
        <div {...api.value.getRootProps()}>
            <div {...api.value.getViewportProps()}>
                <img
                    src="https://picsum.photos/seed/crop/640/400"
                    crossOrigin="anonymous"
                    {...api.value.getImageProps()}
                />

                <div {...api.value.getSelectionProps()}>
                    @for (const position of imageCropper.handles; key position) {
                        <div {...api.value.getHandleProps({ position })}>
                            <span />
                        </div>
                    }
                </div>
            </div>
        </div>
    }

    <div data-scope="image-cropper" data-part="br" />

    <div data-scope="image-cropper" data-part="preview">
        @if (previewUrl.value) {
            <div data-scope="image-cropper" data-part="preview-container">
                <img
                    src={previewUrl.value}
                    alt="Cropped preview"
                    data-scope="image-cropper"
                    data-part="preview-image"
                />
            </div>
        }

        <div data-scope="image-cropper" data-part="controls">
            <button onClick={previewUrl.value ? resetCrop : updatePreview} data-scope="image-cropper" data-part="preview-button">
                {previewUrl.value ? 'Reset Crop' : 'Crop Image'}
            </button>
        </div>
    </div>
    </>
}
