using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterFlow : MonoBehaviour {

	public Vector2 MainFlow;
	public Vector2 DetailFlow;
	public Material waterMaterial;

	void Update() {
		if (waterMaterial != null) {
			waterMaterial.SetTextureOffset("_MainTex", MainFlow * Time.time);
			waterMaterial.SetTextureOffset("_DetailAlbedoMap", DetailFlow * Time.time);
		}
	}
}
